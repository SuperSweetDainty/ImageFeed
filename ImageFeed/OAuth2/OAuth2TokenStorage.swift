import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
            UserDefaults.standard.synchronize()
        }
    }
}
