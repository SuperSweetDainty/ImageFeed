import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled: Bool = false
    var didTapLogoutButtonCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapExitButton() {
        didTapLogoutButtonCalled = true
    }
} 
