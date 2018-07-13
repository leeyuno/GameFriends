//
//  myClanCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 15..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class myClanCell: UITableViewCell {

    @IBOutlet weak var clanName: UILabel!
    @IBOutlet weak var clanComment: UILabel!
    @IBOutlet weak var clanUser: UILabel!
    @IBOutlet weak var clanImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clanImage.layer.masksToBounds = true
        clanImage.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
