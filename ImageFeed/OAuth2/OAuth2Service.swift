import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let dataStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared

    private (set) var authToken: String? {
        get {
            return dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }

    private init() { }

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Error - Failed to create OAuth token request for code: \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        print("[OAuth2Service]: Sending OAuth token request: \(request)")

        let task = object(for: request) { [weak self] result in
            guard let self = self else {
                print("[OAuth2Service]: Error - Self is nil in completion handler")
                return
            }

            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                print("[OAuth2Service]: Successfully received auth token")
                completion(.success(authToken))
            case .failure(let error):
                print("[OAuth2Service]: Failed to fetch token with error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }


    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service]: Error - Failed to create URLComponents for token request")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            print("[OAuth2Service]: Error - Failed to create URL from URLComponents: \(urlComponents)")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        
        print("[OAuth2Service]: Created OAuth token request for URL: \(authTokenUrl)")
        
        return request
    }


    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}

// MARK: - Network Client

extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let task = urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                } catch {
                    let decodingError = error as NSError
                    var errorMessage = "Failed to decode OAuthTokenResponseBody: \(decodingError.localizedDescription)"
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        errorMessage += "\nResponse body: \(responseString)"
                    }
                    
                    print("[Decoding Error]: \(errorMessage)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                if case let NetworkError.httpStatusCode(statusCode) = error, statusCode >= 300 {
                    print("[Server Error]: Unsplash API returned error - HTTP \(statusCode)")
                    if let url = request.url {
                        print("[Server Error]: Request URL: \(url.absoluteString)")
                    }
                }
                completion(.failure(error))
            }
        }
        return task
    }
}
