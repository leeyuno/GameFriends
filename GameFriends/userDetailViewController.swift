//
//  userDetailViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 11. 2..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class userDetailViewController: UIViewController {
    
    var clanId = ""
    var userId = ""

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var userSpot: UILabel!
    @IBOutlet weak var userGender: UILabel!
    @IBOutlet weak var userBirth: UILabel!
    @IBOutlet weak var userRate: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var hoGame1: UILabel!
    @IBOutlet weak var hoGame2: UILabel!
    @IBOutlet weak var hoGame3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadData()
        
        userNickname.layer.masksToBounds = true
        userNickname.layer.cornerRadius = 10
        userNickname.layer.borderColor = UIColor.lightGray.cgColor
        userNickname.layer.borderWidth = 0.3
        
        userSpot.layer.masksToBounds = true
        userSpot.layer.cornerRadius = 10
        userSpot.layer.borderColor = UIColor.lightGray.cgColor
        userSpot.layer.borderWidth = 0.3
        
        userGender.layer.masksToBounds = true
        userGender.layer.cornerRadius = 10
        userGender.layer.borderColor = UIColor.lightGray.cgColor
        userGender.layer.borderWidth = 0.3
        
        userBirth.layer.masksToBounds = true
        userBirth.layer.cornerRadius = 10
        userBirth.layer.borderColor = UIColor.lightGray.cgColor
        userBirth.layer.borderWidth = 0.3
        
        userRate.layer.masksToBounds = true
        userRate.layer.cornerRadius = 10
        userRate.layer.borderColor = UIColor.lightGray.cgColor
        userRate.layer.borderWidth = 0.3
        
        userInfo.layer.masksToBounds = true
        userInfo.layer.cornerRadius = 10
        userInfo.layer.borderColor = UIColor.lightGray.cgColor
        userInfo.layer.borderWidth = 0.3
        
        hoGame1.layer.masksToBounds = true
        hoGame1.layer.cornerRadius = 10
        hoGame1.layer.borderColor = UIColor.lightGray.cgColor
        hoGame1.layer.borderWidth = 0.3
        
        hoGame2.layer.masksToBounds = true
        hoGame2.layer.cornerRadius = 10
        hoGame2.layer.borderColor = UIColor.lightGray.cgColor
        hoGame2.layer.borderWidth = 0.3
        
        hoGame3.layer.masksToBounds = true
        hoGame3.layer.cornerRadius = 10
        hoGame3.layer.borderColor = UIColor.lightGray.cgColor
        hoGame3.layer.borderWidth = 0.3
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/user/touch")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userId)", "clanid" : "\(self.clanId)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                        let userArray = parseJSON["result"] as? String
                        
                        if userArray == "0" {
                            print("서버에러")
                        } else if userArray == "2" {
                            print("데이터 없음")
                        } else {
                            let userObject = parseJSON["result"] as! [String : AnyObject]
                            print(userObject)
                            let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(userObject["imageId"] as! String)")
                            self.userImage.downloadedFrom(url: imageUrl!)
                            self.userImage.contentMode = .scaleToFill
                            
                            self.userInfo.text = userObject["info"] as! String
                            self.userNickname.text = userObject["nick"] as! String
                            self.userRate.text = userObject["rate"] as! String
                            
//                            if userObject["sex"] as! String == "male" {
//                                self.userGender.text = "남자"
//                            } else if userObject["sex"] as! String == "female" {
//                                self.userGender.text = "여자"
//                            }
                            
                            self.userGender.text = userObject["sex"] as! String
                            self.userSpot.text = userObject["spot"] as! String
                            self.userBirth.text = userObject["birth"] as! String
                            
                            self.hoGame1.text = userObject["hoGame1"] as! String
                            self.hoGame2.text = userObject["hoGame2"] as! String
                            self.hoGame3.text = userObject["hoGame3"] as! String
                        }
                        
                    } catch {
                        print("유저데이터 파싱 에러")
                    }
                }
            }
        }) .resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
