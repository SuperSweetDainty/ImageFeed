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
                var errorMessage = "[URLSession+data]: Network request failed: \(nsError.domain) - \(nsError.code)"
                
                if let url = request.url {
                    errorMessage += "[URLSession+data]: Request for URL: \(url.absoluteString)"
                }
                
                if nsError.code == NSURLErrorCancelled {
                    errorMessage += "[URLSession+data]: Request was cancelled"
                }
                
                print("[URLSession+data]: Network error\(errorMessage)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[URLSession+data]: Received invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let statusCode = httpResponse.statusCode
                var errorMessage = "[URLSession+data]: Server returned HTTP \(statusCode)"
                
                if let url = request.url {
                    errorMessage += "[URLSession+data]: Request for URL: \(url.absoluteString)"
                }
                
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    errorMessage += "\nResponse body: \(responseBody)"
                }
                
                print("[URLSession+data]: Network Error \(errorMessage)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
                return
            }
            
            guard let data = data else {
                print("[URLSession+data]: Network error received empty data for \(request.url?.absoluteString ?? "unknown URL")")
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
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = self.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    let responseString = String(data: data, encoding: .utf8) ?? "nil"
                    print("[URLSession+data]: objectTask decoding error - \(error.localizedDescription), response: \(responseString)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[URLSession+data]: objectTask failure - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
