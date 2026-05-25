//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Leo Gabuev on 24.05.2026.
//

import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() 
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Кнопка не найдена")
        loginButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        sleep(3)
        
        loginTextField.tap()
        
        loginTextField.typeText("...@mail.ru")
        webView.swipeUp()
        
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("pass")
        webView.swipeUp()
        
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        sleep(10)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(10)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        sleep(10)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(10)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts["@"].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
