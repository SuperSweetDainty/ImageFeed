import Foundation

enum Constants {
    static let accessKey = "elw8fVRTyxrax_u8IS7Qu_MDuicPoA88mOA0SqV_AlM"
    static let secretKey = "kWirIvql4q83r4-RvABEtnR1w__7L1t-0iGktTR5YHI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURL: URL = {
        let urlString = "https://api.unsplash.com/"
        guard let url = URL(string: urlString) else {
            // Логируем ошибку в DEBUG
            assertionFailure("Invalid URL string: \(urlString)")
            // В релизе упадёт только если URL сломан (что невозможно для hardcoded-строки)
            preconditionFailure("Critical: Invalid hardcoded URL - fix Constants.defaultBaseURL")
        }
        return url
    }()
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}
