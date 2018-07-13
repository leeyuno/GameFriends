//
//  clanAllowViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class clanAllowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, allowDelegate {
    
    var userid = ""
    var clanid = ""
    var maxMember = 10000
    
    @IBOutlet weak var memberTable: UITableView!
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
        let nib = UINib(nibName: "allowCell", bundle: nil)
        memberTable.register(nib, forCellReuseIdentifier: "allowCell")
        memberTable.bounces = false
        memberTable.delegate = self
        memberTable.dataSource = self
        memberTable.reloadData()
    }
    
    func reloadTableView() {
        loadClanData()
    }
    
    func memberOver() {
        let alert = UIAlertController(title: "인원수 초과", message: "클랜인원이 최대입니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func rejectAlert() {
        let alert = UIAlertController(title: "승인", message: "가입을 거절했습니다..", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(done)
        self.present(alert, animated: true, completion: nil)
    }
    
    func allowAlert() {
        let alert = UIAlertController(title: "승인", message: "가입을 승인했습니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(done)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadClanData() {
        memberObject.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/click")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)"]
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
                            
                            let memberList = arrJSON["member"] as! NSArray
                            
                            if memberList.count > 0 {
                                for i in 0 ... memberList.count - 1 {
                                    let memberArray = memberList[i] as! [String : AnyObject]
                                    
                                    if memberArray["check"] as! Bool == false {
                                        self.memberObject.append([memberArray["name"] as! String, memberArray["subTitle"] as! String, memberArray["imageId"] as! String, memberArray["id"] as! String])
                                    }
                                }
                            }
                            self.configureTableView()
                        }

                    } catch {
                        print("클랜데이터 파싱 캐치")
                    }
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "allowCell", for: indexPath) as! allowCell
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(memberObject[indexPath.row][2])")
        
        cell.userNickname.text = memberObject[indexPath.row][0]
        cell.userSubtitle.text = memberObject[indexPath.row][1]
        cell.userImage.downloadedFrom(url: imageUrl!)
        cell.userImage.contentMode = .scaleToFill
        cell.clanid = self.clanid
        cell.userid = self.userid
        cell.maxMember = self.maxMember
        cell.examid = memberObject[indexPath.row][3]
        
        cell.allowDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.memberTable.frame.size.height / 10
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
