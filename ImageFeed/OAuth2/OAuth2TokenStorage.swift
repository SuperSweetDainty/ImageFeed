import Foundation

final class OAuth2TokenStorage {
    private let dataStorage =  UserDefaults.standard
    private let tokenKey = "token"

    var token: String? {
        get {
            dataStorage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
    }
}
