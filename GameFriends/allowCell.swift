//
//  allowCell.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

protocol allowDelegate: class {
    func reloadTableView()
    func memberOver()
    func rejectAlert()
    func allowAlert()
}

class allowCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var userSubtitle: UILabel!
    @IBOutlet weak var allowButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var clanid = ""
    var userid = ""
    var examid = ""
    var maxMember = 10000
    
    weak var allowDelegate: allowDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        allowButton.layer.masksToBounds = true
        allowButton.layer.cornerRadius = 10
        allowButton.layer.borderColor = UIColor.lightGray.cgColor
        allowButton.layer.borderWidth = 0.5
        
        rejectButton.layer.masksToBounds = true
        rejectButton.layer.cornerRadius = 10
        rejectButton.layer.borderColor = UIColor.lightGray.cgColor
        rejectButton.layer.borderWidth = 0.5
        
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 10
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.borderWidth = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func exam(_ check: String) {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/exam")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)", "examid" : "\(self.examid)", "check" : "\(check)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                } catch {
                    print("aaaaa")
                }
            }
        }) .resume()
    }
    
    @IBAction func allowButton(_ sender: Any) {
        if maxMember >= 10000 {
            self.allowDelegate?.memberOver()
        } else {
            self.exam("true")
            self.allowDelegate?.allowAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.allowDelegate?.reloadTableView()
            }
        }
    }
    
    @IBAction func rejectButton(_ sender: Any) {
        
        self.allowDelegate?.rejectAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.allowDelegate?.reloadTableView()
        }
    }
    
}
