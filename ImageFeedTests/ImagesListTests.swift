@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        var presenter = ImagesListPresenterSpy()
        viewController.configure(&presenter)
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableAnimated() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = viewController
        // when
        presenter.view?.updateTableAnimated(oldCount: 0, newCount: 1)
        // then
        XCTAssertTrue(viewController.updateTableAnimatedCalled)
        XCTAssertEqual(viewController.oldCount, 0)
        XCTAssertEqual(viewController.newCount, 1)
    }
    
    func testPresenterCallsReloadTable() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = viewController
        // when
        presenter.view?.reloadTable()
        // then
        XCTAssertTrue(viewController.reloadTableCalled)
    }
    
    func testPresenterCallsShowLikeError() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = viewController
        // when
        presenter.view?.showLikeError()
        // then
        XCTAssertTrue(viewController.showLikeErrorCalled)
    }
    
    func testViewControllerCallsDidTapLike() {
        // given
        let presenter = ImagesListPresenterSpy()
        // when
        presenter.didTapLike(at: 0)
        // then
        XCTAssertEqual(presenter.didTapLikeIndex, 0)
    }
}
