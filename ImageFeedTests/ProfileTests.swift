@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        var presenter = ProfilePresenterSpy()
        viewController.configure(&presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileConfiguration = ProfileConfiguration()
        let testProfile = Profile(username: "username", name: "name", loginName: "@loginName", bio: "bio")
        profileConfiguration.setProfile(testProfile)
        var presenter = ProfilePresenter(profileService: profileConfiguration)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.receivedName, "username")
        XCTAssertEqual(viewController.receivedLoginName, "@loginName")
        XCTAssertEqual(viewController.receivedBio, "bio")
    }
    
    func testPresenterCallsShowLogoutAlert() {
        //given
        let viewController = ProfileViewControllerSpy()
        var presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.didTapExitButton()
        
        //then
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }
    
    func testViewControllerCallsDidTapLogoutButton() {
        //given
        let viewController = ProfileViewController()
        var presenter = ProfilePresenterSpy()
        viewController.configure(&presenter)
        
        //when
        viewController.didTapExitButton()
        
        //then
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
}
