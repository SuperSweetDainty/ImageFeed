import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService] Invalid base URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread, "[ProfileService] fetchProfile must be called on main thread")
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService] Failed to create URLRequest")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profileResult):
                    let fullName = [profileResult.firstName, profileResult.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                        .trimmingCharacters(in: .whitespaces)
                    
                    let profile = Profile(
                        username: profileResult.username,
                        name: fullName,
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio ?? ""
                    )
                    
                    self.profile = profile
                    completion(.success(profile))
                    
                case .failure(let error):
                    print("[ProfileService]: Token fetch failed - \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = currentTask
        currentTask.resume()
    }
}

enum ProfileServiceError: Error {
    case invalidRequest
}

struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}
