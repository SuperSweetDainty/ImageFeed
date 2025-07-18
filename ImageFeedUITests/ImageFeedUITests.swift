import XCTest
import UIKit

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("danya.laputin@mail.ru")
        app.swipeDown()
        webView.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 2)
        
        UIPasteboard.general.string = "Hokage_2004"
        passwordTextField.doubleTap()
        
        if app.menuItems["Paste"].exists {
            app.menuItems["Paste"].tap()
        }
        
        let allowPasteAlert = app.alerts.firstMatch
        if allowPasteAlert.waitForExistence(timeout: 2) {
            let allowButton = allowPasteAlert.buttons["Allow Paste"]
            if allowButton.exists {
                allowButton.tap()
            }
        }
        
        Thread.sleep(forTimeInterval: 2)
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        Thread.sleep(forTimeInterval: 5)
        
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 2))
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 1))
        
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 1))
        let initialValue = likeButton.value as? String ?? "off"
        likeButton.tap()
        let newValue = likeButton.value as? String ?? "off"
        XCTAssertNotEqual(initialValue, newValue, "Включение/выключение лайка")
        likeButton.tap()
        firstCell.tap()
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        image.pinch(withScale: 2, velocity: 1)
        image.pinch(withScale: 0.9, velocity: -1)
        let navBackButton = app.buttons["BackButtonWhite"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        XCTAssertTrue(tableView.waitForExistence(timeout: 5))
        
        tableView.swipeUp()
        XCTAssertTrue(tableView.exists)
    }
    
    func testProfile() throws {
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["userNameLabel"].exists)
        XCTAssertTrue(app.staticTexts["userLoginLabel"].exists)
        
        app.buttons["Exit"].tap()
        app.alerts["Выход из аккаунта"].scrollViews.otherElements.buttons["Выйти"].tap()
    }
}
