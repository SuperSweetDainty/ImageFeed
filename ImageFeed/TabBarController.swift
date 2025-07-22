import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("[TabBarController]: Ошибка приведения типа ImagesListViewController")
            return
        }
        
        var imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(&imagesListPresenter)
        let profileViewController = ProfileViewController()
        var profilePresenter = ProfilePresenter()
        profileViewController.configure(&profilePresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "TabProfileActive"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
