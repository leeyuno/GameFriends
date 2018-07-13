//
//  boardCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 7..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class boardCell: UITableViewCell {

    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet weak var boardContents: UILabel!
    @IBOutlet weak var boardNick: UILabel!
    @IBOutlet weak var boardTitle: UILabel!
    @IBOutlet weak var boardTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        boardImage.contentMode = .scaleToFill
        boardImage.layer.masksToBounds = true
        boardImage.layer.borderWidth = 0.4
        boardImage.layer.borderColor = UIColor.lightGray.cgColor
//        boardImage.layer.cornerRadius = boardImage.frame.size.height / 2
        boardImage.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
