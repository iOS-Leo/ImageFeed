import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - Constants
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Properties
    weak var delegate: ImagesListCellDelegate?
    private var animationLayers = Set<CALayer>()
    
    enum FeedCellImageState {
        case loading
        case error
        case finished(UIImage)
    }
    
    // MARK: - Outlets
    private let cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .ypWhiteIOS.withAlphaComponent(0.1)
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        removeCellShimmers()
        cellImage.image = nil
        dateLabel.text = nil
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animationLayers.forEach { gradient in
            gradient.frame = cellImage.bounds
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Actions
    @objc private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImageName = isLiked ? "likeEnable" : "likeDisable"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
    
    func configCell(
        with textureURLString: String,
        date: String,
        isLiked: Bool,
        completion: @escaping (Result<RetrieveImageResult, KingfisherError>) -> Void
    ) {
        dateLabel.text = date
        setIsLiked(isLiked)
        
        let placeholder = UIImage(named: "Stub")
        
        guard let url = URL(string: textureURLString) else { return }
        
        cellImage.kf.indicatorType = .none
        render(state: .loading)
        
        cellImage.kf.setImage(with: url, placeholder: placeholder) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                self.render(state: .finished(value.image))
            case .failure(_):
                self.render(state: .error)
            }
            completion(result)
        }
    }
    
    // MARK: - Private Methods
    private func render(state: FeedCellImageState) {
        switch state {
        case .loading:
            startCellShimmer()
            cellImage.image = nil
        case .error:
            removeCellShimmers()
            cellImage.image = UIImage(named: "Stub")
        case .finished(let image):
            removeCellShimmers()
            cellImage.image = image
        }
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .ypBlackIOS
        
        contentView.addSubview(cellImage)
        cellImage.addSubview(dateLabel)
        contentView.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func startCellShimmer() {
        cellImage.layer.masksToBounds = true
        
        let gradient = ShimmerAnimationHelper.shared.createGradient(for: cellImage, cornerRadius: 16)
        
        animationLayers.insert(gradient)
        cellImage.layer.addSublayer(gradient)
    }
    
    private func removeCellShimmers() {
        animationLayers.forEach { gradient in
            gradient.removeAnimation(forKey: "locationsChange")
            gradient.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}


