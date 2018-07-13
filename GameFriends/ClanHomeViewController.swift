//
//  ClanHomeViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class ClanHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var clanId = ""
    var author = ""
    var buttonTitle = ""
    
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var clanName: UILabel!
    @IBOutlet weak var clanComment: UILabel!
    @IBOutlet weak var clanComment2: UITextView!
    @IBOutlet weak var clanSpot: UILabel!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var clanImage: UIImageView!
    
    var selectedUserId = ""
    
    @IBOutlet weak var ispushNoti: UISwitch!
    var isRegister = false
    
    var maxMemer = 0
    var userid = ""
    var userNick = ""
    var imageId = ""
    var clanImageId = ""
    var subTitle = ""
    var game = ""
    
    @IBOutlet weak var pushSwitch: UISwitch!

    var userArray = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        useTabBar(true)
        
        ispushNoti.isEnabled = false
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                userid = match.value(forKey: "id") as! String
                userNick = match.value(forKey: "nickname") as! String
                imageId = match.value(forKey: "imageId") as! String
                subTitle = match.value(forKey: "comment") as! String
            } else {
                print("nothing founded")
            }
        } catch {
            print("catch")
        }
        
        self.clanData()
        
        clanImage.layer.masksToBounds = true
        clanImage.layer.borderColor = UIColor.lightGray.cgColor
        clanImage.layer.borderWidth = 0.4
        clanImage.layer.cornerRadius = 10
//        clanImage.contentMode = .scaleToFill

        clanComment2.isEditable = false
        
        //self.clanData()
        
        //가입된 사용자 or 관리자일 경우 -> 가입하기, 설정 버튼 숨기기
        //registButton.isEnabled = false
        //settingButton.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registButton.titleLabel?.text = buttonTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.clanData()
        
        DispatchQueue.main.async {
            let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_download/\(self.clanImageId)")
            self.clanImage.downloadedFrom(url: imageUrl!)
            self.clanImage.contentMode = .scaleToFill
        }

    }
    
    func configureTableView() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        userTable.register(nib, forCellReuseIdentifier: "userCell")
        userTable.bounces = false
        userTable.delegate = self
        userTable.dataSource = self
        userTable.reloadData()
    }
    
    @IBAction func isPushNoti(_ sender: Any) {
        self.pushUpdate()
    }
    
    func pushUpdate() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/push")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "clanid" : "\(self.clanId)", "check" : "\(ispushNoti.isOn)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
//                print(response)
                let httpResponse = response as! HTTPURLResponse
                print(httpResponse.statusCode)
            }
            
        }) .resume()
    }
    
    func clanData() {
        userArray.removeAll()
        let dataUrl = URL(string: URLLib.urlObject.serverUrl + "/clan/click")
        var request = URLRequest(url: dataUrl!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanId)", "userid" : "\(self.userid)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                        
                        let pushData = parseJSON["push"] as? Bool
                        if pushData == true {
                            self.pushSwitch.isOn = true
                        } else if pushData == false {
                            self.pushSwitch.isOn = false
                        }
                        
                        let arrJSON = parseJSON["result"] as? [String : AnyObject]
                        
                        self.clanName.text = arrJSON?["id"] as! String
                        self.clanSpot.text = arrJSON?["spot"] as! String
                        self.clanComment.text = arrJSON?["subTitle"] as! String
                        self.clanComment2.text = arrJSON?["info"] as! String
                        self.author = arrJSON?["author"] as! String
                        self.game = arrJSON?["game"] as! String
                        
                        //self.clanImageId = arrJSON?["imageId"] as! String
                        
                        let memberList = arrJSON?["member"] as! NSArray
                        self.maxMemer = memberList.count
                        
                        if memberList.count > 0 {
                            for i in 0 ... memberList.count - 1 {
                                let memberArray = memberList[i] as! [String : AnyObject]
                                
                                if memberArray["id"] as! String == self.userid {
                                    if memberArray["check"] as! Bool == true {
                                        
//                                        self.isRegister = true
                                        self.ispushNoti.isEnabled = true
                                        self.useTabBar(true)
                                        self.buttonTitle = "탈퇴하기"
                                        break
                                    } else {
                                        
                                        self.buttonTitle = "가입대기"
//                                        self.ispushNoti.isEnabled = true
                                        self.pushUpdate()
                                        self.registButton.isEnabled = false
                                        
                                        self.useTabBar(false)
                                        break
                                    }
                                } else {
                                    
                                    self.useTabBar(false)
                                    self.buttonTitle = "가입하기"
                                }
                                
                            }
                            
                            if memberList.count > 0 {
                                for i in 0 ... memberList.count - 1 {
                                    let memberArray = memberList[i] as! [String : AnyObject]
                                    if memberArray["check"] as! Bool == true {
                                        self.userArray.append([memberArray["name"] as! String, memberArray["subTitle"] as! String, memberArray["imageId"] as! String, memberArray["id"] as! String])
                                    }
                                }
                            }
                            
                            //유저가 관리자면 클랜페쇄버튼, 일반사용자라면 가입유무를 판단해서 가입, 탈퇴 버튼을 만들어줌
                            if self.userid == self.author {
                                self.useTabBar(true)
                                self.settingButton.isHidden = false
                                self.buttonTitle = "클랜폐쇄"
                            } else {
                                self.settingButton.isHidden = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.configureTableView()
                            }
                        }
                    } catch {
                        print("clan data load error")
                    }
                }
            }
            
        }) .resume()
    }
    
    func useTabBar(_ check: Bool) {
        if check == true {
            let tabBarControllerItems = self.tabBarController?.tabBar.items
            
            if let tabArray = tabBarControllerItems {
                for i in 0 ... 3 {
                    tabArray[i].isEnabled = true
                }
            }
        } else if check == false {
            let tabBarControllerItems = self.tabBarController?.tabBar.items
            
            if let tabArray = tabBarControllerItems {
                for i in 0 ... 3 {
                    tabArray[i].isEnabled = false
                }
            }
        }
    }
    
    func exitCheck() {
        let alert = UIAlertController(title: "클랜탈퇴", message: "정말 클랜을 탈퇴하시겠습니까?", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            self.exitClan()
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(done)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func exitClan() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/exit")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanId)", "userid" : "\(self.userid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                DispatchQueue.main.async {
                    self.clanData()
                }
            }
            
        }) .resume()
    }
    
    func destory() {
        let alert = UIAlertController(title: "클랜폐쇄", message: "정말로 클랜을 폐쇄하시겠습니까?", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            self.clanDestroy()
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(done)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func clanDestroy() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/destroy")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanId)", "userid" : "\(self.userid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
             
                if httpResponse.statusCode == 200 {
                    self.destroyDone()
                }
            }
            
        }) .resume()
    }
    
    func clanExam() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/exam")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "", "userid" : "", "examid" : ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
            }
            
        }) .resume()
    }
    
    @IBAction func registButton(_ sender: Any) {
        if (registButton.titleLabel?.text)! == "가입하기" {
            self.registration()
        } else if (registButton.titleLabel?.text)! == "탈퇴하기" {
            self.exitCheck()
        } else if (registButton.titleLabel?.text)! == "클랜폐쇄" {
            self.destory()
        }
    }
    
    func destroyDone() {
        let alert = UIAlertController(title: "클랜이 폐쇄되었습니다.", message: "클랜을 정상적으로 폐쇄하였습니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: { action -> Void in
            self.exitSegue()
        })
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func exit() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/exit")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanId)", "userid" : "\(self.userid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
                
                if httpResponse.statusCode == 200 {
                    self.exitDone()
                }
            }
            
            
        }) .resume()
    }
    
    func exitDone() {
        let alert = UIAlertController(title: "클랜탈퇴", message: "클랜탈퇴", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: { action -> Void in
            self.exitSegue()
        })
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func exitSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "exitSegue", sender: self)
        }
    }
    
    func registrationDone() {
        let alert = UIAlertController(title: "가입신청", message: "가입신청이 성공적으로 완료되었습니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
        
        self.registButton.titleLabel?.text = "탈퇴하기"
    }
    
    func registration() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/join")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanId)", "usernick" : "\(self.userNick)", "userid" : "\(self.userid)", "imageid" : "\(self.imageId)", "subTitle" : "\(self.subTitle)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    do {
                        self.registrationDone()
                    } catch {
                        print("sdlfjndsf;kdjsn")
                    }
                    
                } else if httpResponse.statusCode == 409 {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "클랜 최대인원이 초과했습니다.", message: "클랜이 최대인원입니다.", preferredStyle: .alert)
                        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                        
                        alert.addAction(done)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }) .resume()
    }
    
    
    
    @IBAction func settingButton(_ sender: Any) {
        self.settingSegue()
    }
    
    func settingSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "settingSegue", sender: self)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell

        cell.userNick.text = userArray[indexPath.row][0]
        cell.userComment.text = userArray[indexPath.row][1]

        DispatchQueue.main.async {
            let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(self.userArray[indexPath.row][2])")
            cell.userImage.downloadedFrom(url: imageUrl!)
            cell.userImage.contentMode = .scaleToFill
        }
        if userArray[indexPath.row][3] == self.author {
            cell.author.text = "길드장"
        } else {
            cell.author.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUserId = userArray[indexPath.row][3]
        self.userSegue()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "클랜 멤버"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func userSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "userSegue", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "userSegue" {
            let vc = segue.destination as! userDetailViewController
            vc.clanId = self.clanId
            vc.userId = self.selectedUserId
        }
        
        if segue.identifier == "settingSegue" {
            let destination = (segue.destination as! clanSubTabBarViewController).viewControllers![2] as! clanDataUpdateViewController
            destination.tmpClanComment = self.clanComment.text!
            destination.tmpClanComment2 = self.clanComment2.text!
            destination.tmpClanName = self.clanName.text!
            destination.tmpClanSpot = self.clanSpot.text!
            destination.game = self.game
            destination.tmpClanImage = self.clanImageId
            destination.clanid = self.clanId
            destination.userid = self.userid
            
            let destination2 = (segue.destination as! clanSubTabBarViewController).viewControllers![1] as! clanMemberViewController
            destination2.userid = self.userid
            destination2.clanid = self.clanId
            
            let destination3 = (segue.destination as! clanSubTabBarViewController).viewControllers![0] as! clanAllowViewController
            destination3.clanid = self.clanId
            destination3.userid = self.userid
            destination3.maxMember = self.maxMemer
        }
    }
 
    

}
