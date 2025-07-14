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
                    // Показываем ошибку
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
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width)
        let y = (newContentSize.height - visibleRectSize.height)
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
