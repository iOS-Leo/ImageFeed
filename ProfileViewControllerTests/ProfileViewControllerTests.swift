import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var confirmLogoutCalled = false
    
    weak var view: ProfileViewOutput?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutCalled = true
    }
    
    func confirmLogout() {
        confirmLogoutCalled = true
    }
}

final class ProfileViewControllerTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        
        viewController.configure(presenterSpy)
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerCallsDidTapLogoutOnButtonTap() {
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        
        viewController.logoutButton.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(presenterSpy.didTapLogoutCalled)
    }
}
