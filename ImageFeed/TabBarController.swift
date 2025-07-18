import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        // Создаём ImagesListViewController
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("Не удалось привести ImagesListViewController")
            return
        }

        // Создаём презентер и конфигурируем VC
        var imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(&imagesListPresenter)

        // Создаём ProfileViewController и его презентер
        let profileViewController = ProfileViewController()
        var profilePresenter = ProfilePresenter()
        profileViewController.configure(&profilePresenter)

        // Устанавливаем табы
//        imagesListViewController.tabBarItem = UITabBarItem(
//            title: "",
//            image: UIImage(named: "TabProfileActive"),
//            selectedImage: nil
//        )

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "TabProfileActive"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
