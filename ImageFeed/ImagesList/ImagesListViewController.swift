import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private weak var tableView: UITableView!
    private let imagesListService = ImagesListService.shared
    
    
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        if oldCount == newCount { return }
        
        tableView.performBatchUpdates {
            let newIndexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            photos = imagesListService.photos
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController]: Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            guard let imageURL = URL(string: photo.largeImageURL) else { return }
            
            viewController.imageURL = imageURL
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let imageURL = URL(string: photo.largeImageURL) else { return }
        
        cell.cellImage.backgroundColor = UIColor(named: "YP Grey")
        cell.cellImage.contentMode = .center
        cell.cellImage.kf.indicatorType = .activity
        
        cell.cellImage.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: "Stub")
        ) { [weak cell] result in
            guard let cell else { return }
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

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let newLikeStatus = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self else { return }
                
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        let oldPhoto = self.photos[index]
                        let newPhoto = Photo(
                            id: oldPhoto.id,
                            size: oldPhoto.size,
                            createdAt: oldPhoto.createdAt,
                            welcomeDescription: oldPhoto.welcomeDescription,
                            thumbImageURL: oldPhoto.thumbImageURL,
                            largeImageURL: oldPhoto.largeImageURL,
                            isLiked: !oldPhoto.isLiked
                        )
                        
                        self.photos[index] = newPhoto
                        
                        if let visibleCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
                            visibleCell.setIsLiked(newPhoto.isLiked)
                        } else {
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    }
                    
                case .failure:
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось поставить лайк. Попробуйте позже.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
