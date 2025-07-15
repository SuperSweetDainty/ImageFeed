import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var isLoading = false
    
    private let dateFormatter = ISO8601DateFormatter()
    
    func quit() {
        photos = []
        lastLoadedPage = nil
        isLoading = false
    }
    
    func fetchPhotosNextPage() {
        guard !isLoading else {
            print("[ImagesListService]: Already loading, skipping request")
            return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]
        
        guard let url = urlComponents.url else {
            print("[ImagesListService]: Failed to create URL for next page")
            return
        }
        
        isLoading = true
        
        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.isLoading = false }
            guard
                let self,
                let data,
                let photoResults = try? JSONDecoder().decode([PhotoResult].self, from: data)
            else {
                print("[ImagesListService]: Failed to decode photo results")
                return
            }
            
            let newPhotos = photoResults.map { self.convert(from: $0) }
            
            DispatchQueue.main.async {
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            }
        }
        
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else {
            assertionFailure("[ImagesListService]: No token found")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("[ImagesListService]: Invalid URL for like request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("[ImagesListService]: Like request failed with error: \(error.localizedDescription)")
                completion(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[ImagesListService]: Like request failed: no HTTP response")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("[ImagesListService]: Like request failed with status code: \(httpResponse.statusCode)")
                completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                self?.photos[index].isLiked = isLike
                print("[ImagesListService]: Photo \(photoId) like status changed to \(isLike)")
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                completion(.success(()))
            }
        }
        
        task.resume()
    }
    
    func updatePhoto(_ photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index] = photo
        }
    }
    
    private func convert(from photoResult: PhotoResult) -> Photo {
        let size = CGSize(width: photoResult.width, height: photoResult.height)
        let createdAt = photoResult.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photo(
            id: photoResult.id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
}
