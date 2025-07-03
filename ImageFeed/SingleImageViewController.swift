import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else {
            print("Image not found")
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        
        present(activityController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.zoomScale = 1.0
        
        imageView.image = image
        imageView.sizeToFit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let image = image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        
        let contentSize = scrollView.contentSize
        let xOffset = (contentSize.width - visibleSize.width) / 2
        let yOffset = (contentSize.height - visibleSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: 0, right: 0)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

