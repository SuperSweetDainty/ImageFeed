@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var didTapLikeIndex: Int?
    var willDisplayIndex: Int?
    
    var photos: [Photo] = []

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplay(at index: Int) {
        willDisplayIndex = index
    }

    func didTapLike(at index: Int) {
        didTapLikeIndex = index
    }
}
