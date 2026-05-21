//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by Leo Gabuev on 21.05.2026.
//

import XCTest
import Foundation
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    func code(from url: URL) -> String? { return nil }
}


final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}



final class WebViewTests: XCTestCase {
    
    private let mockConfiguration = AuthConfiguration(
            accessKey: "mock",
            secretKey: "mock",
            redirectURI: "mock",
            accessScope: "mock",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURLString: "https://api.unsplash.com"
        )
    
    func testViewControllerCallsViewDidLoad() {

        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() async throws {
        try await MainActor.run {
            
            let viewController = WebViewViewControllerSpy()
            
            let authHelper = AuthHelper(configuration: mockConfiguration)
            let presenter = WebViewPresenter(authHelper: authHelper)
            
            viewController.presenter = presenter
            presenter.view = viewController
            
            presenter.viewDidLoad()
            
            XCTAssertTrue(viewController.loadRequestCalled)
        }
    }
    
    func testProgressVisibleWhenLessThenOne() async throws {
            try await MainActor.run {
              
                let authHelper = AuthHelper(configuration: mockConfiguration)
                let presenter = WebViewPresenter(authHelper: authHelper)
                let progress: Float = 0.6
                
                let shouldHideProgress = presenter.shouldHideProgress(for: progress)
                
                XCTAssertFalse(shouldHideProgress)
            }
        }
    
    func testProgressHiddenWhenOne() async throws {
            try await MainActor.run {
                
                let authHelper = AuthHelper(configuration: mockConfiguration)
                let presenter = WebViewPresenter(authHelper: authHelper)
                let progress: Float = 1.0
                
                let shouldHideProgress = presenter.shouldHideProgress(for: progress)
                
                XCTAssertTrue(shouldHideProgress)
            }
        }
    
    func testAuthHelperAuthURL() async throws {
        try await MainActor.run {

            let authHelper = AuthHelper(configuration: mockConfiguration)
            
            let url = authHelper.authURL()

            guard let urlString = url?.absoluteString else {
                XCTFail("Auth URL is nil")
                return
            }

            XCTAssertTrue(urlString.contains(mockConfiguration.authURLString))
            XCTAssertTrue(urlString.contains(mockConfiguration.accessKey))
            XCTAssertTrue(urlString.contains(mockConfiguration.redirectURI))
            XCTAssertTrue(urlString.contains("code"))
            XCTAssertTrue(urlString.contains(mockConfiguration.accessScope))
        }
    }
}
