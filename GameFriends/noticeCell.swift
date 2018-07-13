//
//  noticeCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 17..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class noticeCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var notice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        notice.layer.masksToBounds = true
        notice.layer.cornerRadius = 5
        notice.layer.borderColor = UIColor.lightGray.cgColor
        notice.layer.borderWidth = 0.2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
