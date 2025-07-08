import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var task: URLSessionTask?
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard task == nil else {
            print("[OAuth2Service] Warning: Token request already in progress")
            return
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] Error: Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.task = nil
                }
            }
            
            if let error = error {
                print("[OAuth2Service] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                return
            }
            
            guard let data = data else {
                print("[OAuth2Service] Error: No data in response")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[OAuth2Service] Error: Not a HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                print("[OAuth2Service] Error: Invalid HTTP status - \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                
                guard !response.accessToken.isEmpty else {
                    print("[OAuth2Service] Error: Empty token in response")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.emptyToken))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    OAuth2TokenStorage.shared.token = response.accessToken
                    completion(.success(response.accessToken))
                    print("[OAuth2Service] Token received: \(response.accessToken.prefix(4))...")
                }
            } catch {
                print("[OAuth2Service] Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError(error)))
                }
            }
        }
        
        self.task = task
        task.resume()
        print("[OAuth2Service] Starting token request for code: \(code.prefix(4))...")
    }
}
