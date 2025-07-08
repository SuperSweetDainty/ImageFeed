import UIKit

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "BackButtonBlack")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "BackButtonBlack")
        navigationController?.navigationBar.tintColor = UIColor(named: "YP Black")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        let authTokenFetched: (Result<String, Error>) -> Void = { result in
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                DispatchQueue.main.async {
                    self.delegate?.didAuthenticate(self)
                }
            case .failure(let error):
                print("Ошибка при получении токена: \(error)")
            }
        }
        
        OAuth2Service.shared.fetchOAuthToken(code: code, completion: authTokenFetched)
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
    protocol AuthViewControllerDelegate: AnyObject {
        func didAuthenticate(_ vc: AuthViewController)
    }

