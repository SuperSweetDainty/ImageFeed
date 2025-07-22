import UIKit
import Kingfisher

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    private var presenter: ProfilePresenterProtocol?
    
    func configure<T: ProfilePresenterProtocol>(_ presenter: inout T) {
        self.presenter = presenter
        presenter.view = self
    }
    
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let exitButton = UIButton(type: .system)
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        loginLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func updateAvatar(with url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "UserPicture"),
            options: [.processor(processor), .cacheOriginalImage]
        ) { result in
            switch result {
            case .success:
                print("[ProfileViewController]: Avatar uploaded successfully")
            case .failure(let error):
                print("[ProfileViewController]: Avatar loading error - \(error.localizedDescription)")
            }
        }
    }
    
    func showLogoutAlert() {
        let alertController = UIAlertController(
            title: "Выход из аккаунта",
            message: "Точно хотите выйти?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Выйти", style: .default) { [weak self] _ in
            ProfileLogoutService.shared.logout()
            
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = SplashViewController()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
        guard let window = UIApplication.shared.windows.first else { return }
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }
    
    @objc
    func didTapExitButton() {
        presenter?.didTapExitButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black") ?? .black
        
        setupProfileImage()
        setupExitButton()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        
        presenter?.viewDidLoad()
    }
    
    private func setupProfileImage() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.image = UIImage(named: "UserPicture")
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
        view.addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    
    private func setupExitButton() {
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "Exit")?.withRenderingMode(.alwaysOriginal)
        exitButton.setImage(image, for: .normal)
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
        exitButton.accessibilityIdentifier = "exitButton"
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.text = "Екатерина Новикова"
        nameLabel.accessibilityIdentifier = "userNameLabel"
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupLoginLabel() {
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = .gray
        loginLabel.text = "@ekaterina_nov"
        loginLabel.accessibilityIdentifier = "userLoginLabel"
        view.addSubview(loginLabel)
        
        NSLayoutConstraint.activate([
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Hello, world!"
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
