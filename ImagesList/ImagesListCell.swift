

import UIKit
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var buttonLike: UIButton!

    @IBOutlet weak var dateLabel: UILabel!
    
}
