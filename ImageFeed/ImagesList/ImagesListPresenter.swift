import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableAnimated(oldCount: Int, newCount: Int)
    func reloadTable()
    func showLikeError()
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func didTapLike(at index: Int)
    func willDisplay(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    
    private(set) var photos: [Photo] = []
    private let service = ImagesListService.shared
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let oldCount = self.photos.count
            self.photos = self.service.photos
            let newCount = self.photos.count
            print("[Presenter]: received notification: photos updated")
            self.view?.updateTableAnimated(oldCount: oldCount, newCount: newCount)
        }
        
        print("[Presenter]: viewDidLoad called")
        service.fetchPhotosNextPage()
    }
    
    func didLoadNewPhotos(_ newPhotos: [Photo]) {
        let oldCount = photos.count
        photos.append(contentsOf: newPhotos)
        let newCount = photos.count
        view?.updateTableAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func didTapLike(at index: Int) {
        guard index < photos.count else { return }
        let photo = photos[index]
        let newStatus = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        
        service.changeLike(photoId: photo.id, isLike: newStatus) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                
                switch result {
                case .success:
                    print("[Presenter]: like toggled successfully")
                    self.photos = self.service.photos
                    self.view?.reloadTable()
                case .failure:
                    print("[Presenter]: like toggle failed")
                    self.view?.showLikeError()
                }
            }
        }
    }
    
    func willDisplay(at index: Int) {
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        if !testMode && index + 1 == photos.count {
            print("[Presenter]: fetching next page")
            service.fetchPhotosNextPage()
        }
    }
}
