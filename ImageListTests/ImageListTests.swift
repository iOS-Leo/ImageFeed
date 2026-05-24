import XCTest
@testable import ImageFeed


final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    
    func viewDidLoad() { viewDidLoadCalled = true }
    func fetchPhotosNextPage() { fetchPhotosNextPageCalled = true }
    func changeLike(photoId: String, isLiked: Bool, indexPath: IndexPath) {}
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLikeErrorCalled = false
    var updatedLikeIndexPath: IndexPath?
    var updatedLikeStatus: Bool?
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        updatedLikeIndexPath = indexPath
        updatedLikeStatus = isLiked
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
}

final class ImagesListServiceErrorMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    func fetchPhotosNextPage() {}
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.failure(NSError(domain: "Test", code: 0, userInfo: nil)))
    }
}

final class ImagesListServiceStub: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    func fetchPhotosNextPage() {}
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

final class ImagesListServiceSuccessMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    func fetchPhotosNextPage() {}
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}


final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        let viewSpy = ImagesListViewControllerSpy()
        let serviceStub = ImagesListServiceStub()
        let presenter = ImagesListPresenter(service: serviceStub)
        presenter.view = viewSpy
        
        
        presenter.didUpdatePhotos()
        
        XCTAssertTrue(viewSpy.updateTableViewAnimatedCalled)
    }
    
    func testPresenterShowsErrorOnLikeFailure() {
        let viewSpy = ImagesListViewControllerSpy()
        let errorServiceMock = ImagesListServiceErrorMock()
        let presenter = ImagesListPresenter(service: errorServiceMock)
        presenter.view = viewSpy
        
        presenter.changeLike(photoId: "123", isLiked: false, indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(viewSpy.showLikeErrorCalled, "Презентер должен показать ошибку при неудачном лайке")
    }
}
