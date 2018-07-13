//
//  clanCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 13..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class clanCell: UITableViewCell {

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var clanName: UILabel!
    @IBOutlet weak var clanComment: UILabel!
    @IBOutlet weak var clanImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
