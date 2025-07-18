import Foundation

final class ProfileConfiguration: ProfileServiceProtocol {
    var profile: Profile?
    
    func setProfile(_ profile: Profile) {
        self.profile = profile
    }
}
