
import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updateLike(at indexPath: IndexPath, isLiked: Bool)
    func showLikeError()
}

final class ImagesListViewController: UIViewController {
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Outlets
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .ypBlackIOS
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - DateFormatter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypBlackIOS
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photos[indexPath.row] else {return}
        let dateString = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.delegate = self
        
        cell.configCell(with: photo.thumbImageURL, date: dateString, isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.tableView.performBatchUpdates(nil, completion: nil)
            case .failure(let error):
                print("[ImagesListViewController]: Ошибка загрузки картинки Kingfisher: \(error)")
            }
        }
    }
}


extension ImagesListViewController: ImagesListViewControllerProtocol {
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            return
        }
        
        cell.setIsLiked(isLiked)
    }
    
    func showLikeError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось изменить статус лайка",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        
        present(alert, animated: true)
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
            self.presenter = presenter
            presenter.view = self
        }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let photo = presenter?.photos[indexPath.row] else {
            return
        }
        
        let singleImageVC = SingleImageViewController()
        
        singleImageVC.imageURL = URL(string: photo.largeImageURL)
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == presenter?.photos.count {
            presenter?.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photos[indexPath.row] else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        if imageWidth == 0 { return 0 }
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter?.photos[indexPath.row]
        else {
            return
        }
        
        presenter?.changeLike(
            photoId: photo.id,
            isLiked: photo.isLiked,
            indexPath: indexPath
        )
    }
}
