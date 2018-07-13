//
//  clanMemberViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class clanMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var memberTableView: UITableView!
    
    var clanid = ""
    var userid = ""
    var author = ""
    
    var memberObject = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadClanData()
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        memberTableView.register(nib, forCellReuseIdentifier: "userCell")
        memberTableView.bounces = false
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.reloadData()
    }
    
    func loadClanData() {
        memberObject.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/click")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid": "\(self.userid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        
                        let checkJSON = parseJSON["result"] as? String
                        
                        if checkJSON == "2" {
                            
                        } else {
                            let arrJSON = parseJSON["result"] as! [String : AnyObject]
                            self.author = arrJSON["author"] as! String

                            let memberList = arrJSON["member"] as! NSArray
                            
                            if memberList.count > 0 {
                                for i in 0 ... memberList.count - 1 {
                                    let memberArray = memberList[i] as! [String : AnyObject]
                                    
                                    if memberArray["check"] as! Bool == true {
                                        self.memberObject.append([memberArray["name"] as! String, memberArray["subTitle"] as! String, memberArray["imageId"] as! String, memberArray["id"] as! String])
                                    }
                                }
                            }
                        }
                    } catch {
                        print("클랜데이터 파싱 캐치")
                    }
                    self.configureTableView()
                }
            }
        }) .resume()
    }
    
    func kickUser(_ kickid: String) {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/kick")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)", "kickid" : "\(kickid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print(response)
            }
            
        }) .resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(self.memberObject[indexPath.row][2])")
        
        cell.userNick.text = memberObject[indexPath.row][0]
        cell.userComment.text = memberObject[indexPath.row][1]
        cell.author.text = ""
        cell.userImage.downloadedFrom(url: imageUrl!)
        cell.userImage.contentMode = .scaleToFill
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.memberTableView.frame.size.height / 9
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if memberObject[indexPath.row][3] == self.author {
            let deleteButton = UITableViewRowAction(style: .normal, title: "강퇴", handler: { (action, index) -> Void in
                
                let alert = UIAlertController(title: "강퇴실패", message: "본인은 강퇴할 수 없습니다.", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            })
            
            deleteButton.backgroundColor = UIColor.red
            
            return [deleteButton]
        } else {
            let deleteButton = UITableViewRowAction(style: .normal, title: "강퇴", handler: { (action, index) -> Void in
                
                //서버에 해당 유저를 지우는 함수
                //remove function
                self.kickUser(self.memberObject[indexPath.row][3])
                self.memberObject.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            
            deleteButton.backgroundColor = UIColor.red
            
            return [deleteButton]
        }
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
