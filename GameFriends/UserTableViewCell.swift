//
//  UserTableViewCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 19..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNick: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var author: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 10
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
