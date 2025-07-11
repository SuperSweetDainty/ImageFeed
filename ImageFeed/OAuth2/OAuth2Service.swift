import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let dataStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    
    private(set) var authToken: String? {
        get { dataStorage.token }
        set { dataStorage.token = newValue }
    }
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if code == lastCode {
            if let token = authToken {
                print("[OAuth2Service]: Skipping request - same code, token already set")
                DispatchQueue.main.async {
                    completion(.success(token))
                }
            } else {
                print("[OAuth2Service]: Skipping request - same code, token pending")
            }
            return
        }
        
        if let currentTask = task {
            print("[OAuth2Service]: Cancelling previous token request")
            currentTask.cancel()
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Error - Failed to create request for code \(code)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        print("[OAuth2Service]: Sending new token request for code \(code)")
        lastCode = code
        
        let newTask = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            self.task = nil
            self.lastCode = nil
            
            switch result {
            case .success(let body):
                let token = body.accessToken
                self.authToken = token
                print("[OAuth2Service]: Token fetch success - token: \(token)")
                
                DispatchQueue.main.async {
                    completion(.success(token))
                }
            case .failure(let error):
                print("[OAuth2Service]: Token fetch failed - \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
        
        
        self.task = newTask
        newTask.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service]: Error - Bad URL components")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            print("[OAuth2Service]: Error - Invalid URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
