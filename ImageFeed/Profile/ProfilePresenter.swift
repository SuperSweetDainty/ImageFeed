import UIKit

public protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar(with url: URL)
    func showLogoutAlert()
    func logout()
}

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapExitButton()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared, profileImageService: ProfileImageService = .shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        updateProfileDetails()
        setupAvatarObserver()
        updateAvatarIfNeeded()
    }
    
    func didTapExitButton() {
        view?.showLogoutAlert()
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(name: profile.name, loginName: profile.loginName, bio: profile.bio)
    }
    
    private func setupAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let urlString = userInfo["URL"] as? String,
                      let url = URL(string: urlString) else { return }
                self.view?.updateAvatar(with: url)
            }
    }
    
    private func updateAvatarIfNeeded() {
        if let avatarURL = profileImageService.avatarURL,
           let url = URL(string: avatarURL) {
            view?.updateAvatar(with: url)
        }
    }
}
