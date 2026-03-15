//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 15.03.2026.
//

import UIKit
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var dateLable: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
}
