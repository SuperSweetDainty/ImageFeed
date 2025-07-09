import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                var errorMessage = "Network request failed: \(nsError.domain) - \(nsError.code)"
                
                if let url = request.url {
                    errorMessage += " for URL: \(url.absoluteString)"
                }
                
                if nsError.code == NSURLErrorCancelled {
                    errorMessage += " (Request was cancelled)"
                }
                
                print("[Network Error]: \(errorMessage)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[Network Error]: Received invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let statusCode = httpResponse.statusCode
                var errorMessage = "Server returned HTTP \(statusCode)"
                
                if let url = request.url {
                    errorMessage += " for URL: \(url.absoluteString)"
                }
                
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    errorMessage += "\nResponse body: \(responseBody)"
                }
                
                print("[Network Error]: \(errorMessage)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
                return
            }
            
            guard let data = data else {
                print("[Network Error]: Received empty data for \(request.url?.absoluteString ?? "unknown URL")")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        
        task.resume()
        return task
    }
}
