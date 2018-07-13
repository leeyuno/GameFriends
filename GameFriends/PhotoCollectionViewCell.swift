//
//  PhotoCollectionViewCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var create_at: UILabel!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    func setCornerRadious(_ radious: Int) {
        self.photoImage.layer.masksToBounds = true
        self.photoImage.layer.borderColor = UIColor.darkGray.cgColor
        self.photoImage.layer.borderWidth = 0.5
        self.photoImage.contentMode = .scaleToFill
//        self.photoImage.clipsToBounds = true
        self.photoImage.layer.cornerRadius = CGFloat(radious)
    }
    
}
