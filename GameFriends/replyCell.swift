//
//  replyCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

protocol replyDelegate: class {
//    func deleteFunc(_ replyId: String)
    func alertReplyDelete(_ replyId: String)
//    func deleteContents(_ replyId: String)
}

class replyCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMemo: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var replyDeleteButton: UIButton!
    
    var viewName = ""
    
    weak var replyDelegate: replyDelegate?
    
    var replyId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        replyDeleteButton.isHidden = true
        
//        userImage.contentMode = .scaleToFill
        userImage.layer.masksToBounds = true
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.borderWidth = 0.3
        userImage.layer.cornerRadius = userImage.frame.size.height / 2
    }

    @IBAction func deleteReply(_ sender: Any) {
//        print(replyId)
//        replyDelegate?.deleteFunc(self.replyId)
        replyDelegate?.alertReplyDelete(replyId)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
