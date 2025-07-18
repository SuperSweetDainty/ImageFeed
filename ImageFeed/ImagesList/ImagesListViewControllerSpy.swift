import Foundation

final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    private(set) var updateTableAnimatedCalled = false
    private(set) var reloadTableCalled = false
    private(set) var showLikeErrorCalled = false
    private(set) var oldCount: Int?
    private(set) var newCount: Int?
    
    func updateTableAnimated(oldCount: Int, newCount: Int) {
        updateTableAnimatedCalled = true
        self.oldCount = oldCount
        self.newCount = newCount
    }
    
    func reloadTable() {
        reloadTableCalled = true
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
}
