import UIKit

final class ImagesListViewController: UIViewController {
    private let showImageSegueID = "ShowSingleImage"
    
    @IBOutlet weak private var tableView: UITableView!
    private let photoNames = (0..<20).map(String.init)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == showImageSegueID,
              let destinationVC = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            assertionFailure("Invalid segue configuration or destination")
            return
        }
        
        destinationVC.image = UIImage(named: photoNames[indexPath.row])
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoNames.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photoNames[indexPath.row]
        
        guard let image = UIImage(named: imageName) else {
            return
        }
        
        cell.cellImageView.image = image
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let likeImageName = indexPath.row % 2 == 0 ? "Like" : "Dislike"
        cell.likeImageView.setImage(UIImage(named: likeImageName), for: .normal)
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showImageSegueID, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photoNames[indexPath.row]
        
        guard let image = UIImage(named: imageName) else {
            return 0
        }
        
        let screenWidth = tableView.bounds.width
        let imageSize = image.size
        let aspectRatio = imageSize.height / imageSize.width
        let imageHeight = screenWidth * aspectRatio
        let verticalInsets: CGFloat = 12 + 12
        
        return imageHeight + verticalInsets
    }
}
