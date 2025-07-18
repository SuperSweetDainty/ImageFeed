import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    var updateProfileDetailsCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var showLogoutAlertCalled: Bool = false
    var logoutCalled: Bool = false
    
    var receivedName: String?
    var receivedLoginName: String?
    var receivedBio: String?
    var receivedAvatarURL: URL?
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        receivedName = name
        receivedLoginName = loginName
        receivedBio = bio
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
}
