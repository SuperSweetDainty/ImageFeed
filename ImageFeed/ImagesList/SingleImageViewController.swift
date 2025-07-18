import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let url = imageURL {
            
            UIBlockingProgressHUD.show()
            imageView.kf.setImage(with: url, completionHandler: { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let value):
                    self?.imageView.image = value.image
                    self?.imageView.frame.size = value.image.size
                    self?.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure:
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось загрузить изображение.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self?.present(alert, animated: true)
                }
            })
        }
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()

        let visibleSize = scrollView.bounds.size
        let imageSize = image.size

        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)

        let newImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        let x = max((visibleSize.width - newImageSize.width) / 2, 0)
        let y = max((visibleSize.height - newImageSize.height) / 2, 0)

        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: 0, right: 0)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
