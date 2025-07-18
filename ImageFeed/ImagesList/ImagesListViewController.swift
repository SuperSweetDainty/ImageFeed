import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private weak var tableView: UITableView!
    private var presenter: ImagesListPresenterProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    func configure<T: ImagesListPresenterProtocol>(_ presenter: inout T) {
        self.presenter = presenter
        presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photos[indexPath.row],
                let imageURL = URL(string: photo.largeImageURL)
            else {
                assertionFailure("[ImagesListViewController]: Invalid segue destination")
                return
            }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell
        else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photos[indexPath.row] else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplay(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath.row)
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard
            let photo = presenter?.photos[indexPath.row],
            let imageURL = URL(string: photo.largeImageURL)
        else { return }
        
        cell.cellImage.backgroundColor = UIColor(named: "YP Grey")
        cell.cellImage.contentMode = .center
        cell.cellImage.kf.indicatorType = .activity
        
        cell.cellImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "Stub")) { result in
            switch result {
            case .success:
                cell.cellImage.contentMode = .scaleAspectFill
            case .failure:
                cell.cellImage.contentMode = .center
            }
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: ImagesListViewProtocol {
    func updateTableAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        tableView.reloadData()
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить лайк. Попробуйте позже.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
