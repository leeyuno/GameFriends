    //
//  MyClanViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class MyClanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var id = ""
    var username = ""
    var author = ""
    
    //create view
    @IBOutlet weak var createButton: UIButton!
    
    var clanid = ""
    var clanImageid = ""
    
    var selectCount = 1
    
    var clanList = [[String]]()
    
    var reFreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButton.layer.cornerRadius = createButton.frame.size.width / 2
        
        reFreshControl = UIRefreshControl()
        reFreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        reFreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(reFreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCoreData()
        loadMyClanList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh(_ sender: Any) {
        print("PULL TO REFRESH")
        loadMyClanList()
        reFreshControl.endRefreshing()
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "myClanCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myClanCell")
    
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.bounces = false
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.reloadData()
    }

    @IBAction func createButton(_ sender: Any) {
        //self.showCreateView()
        
        self.createSegue()
    }
    
    func loadCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                id = match.value(forKey: "id") as! String
                username = match.value(forKey: "nickname") as! String
            } else {
                print("Nothing founded")
            }
            
        } catch {
            print("eirjei")
        }
        
    }
    
    func loadMyClanList() {
        self.clanList.removeAll()
        
        let clanUrl = URL(string: URLLib.urlObject.serverUrl + "/clan/me")
        var request = URLRequest(url: clanUrl!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.id)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                
            } else {
                DispatchQueue.main.async {
                    do {
                        //let parseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : NSArray]
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
        
                        let checkJSON = parseJSON["result"] as? String
                        
                        if checkJSON == "2" {
                            let alert = UIAlertController(title: "나의 클랜이 존재하지 않습니다.", message: "클랜을 생성하거나 가입해주세요.", preferredStyle: .alert)
                            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                            alert.addAction(done)
                            
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let parseData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : NSArray]
                            let clanObject = parseData["result"]
                            
                            for i in 0 ... (clanObject?.count)! - 1 {
                                let aObject = clanObject?[i] as! [String :AnyObject]
                                
                                self.clanList.append([aObject["id"] as! String, aObject["subTitle"] as! String, aObject["imageId"] as! String, aObject["author"] as! String])
                                
                                let memberObject = aObject["member"] as! NSArray
                                
                                var Ccount = 0
                                
                                if memberObject.count > 0 {
                                    for i in 0 ... memberObject.count - 1 {
                                        let aObject = memberObject[i] as! [String : AnyObject]
                                        
                                        if aObject["check"] as! Bool == true {
                                            Ccount += 1
                                        }
                                    }
                                    
                                    let memberCount = String(memberObject.count)
                                    self.clanList[i].append(String(Ccount))
                                }
                                
                            }
                            //self.clanList.append
                            
                            self.configureTableView()
                            if self.clanList.count == 0 {
                                self.clanNothing()
                            }
                        }
                    } catch {
                        print("errororror")
                    }
                }
            }
            
        }) .resume()
    }
    
    func clanNothing() {
        let alert = UIAlertController(title: "내 클랜이 존재하지 않습니다.", message: "클랜을 만들거나 가입해보세요.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "selectSegue", sender: self)
        }
    }
    
    func createSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "createSegue", sender: self)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if clanList.count > 0 {
            return clanList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myClanCell", for: indexPath) as! myClanCell
        
        cell.clanName.text = self.clanList[indexPath.row][0]
        cell.clanComment.text = self.clanList[indexPath.row][1]
        cell.clanUser.text = self.clanList[indexPath.row][4] + "명"
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_download/\(self.clanList[indexPath.row][2])")
        cell.clanImage.downloadedFrom(url: imageUrl!)
        cell.clanImage.contentMode = .scaleToFill
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        clanid = clanList[indexPath.row][0]
        clanImageid = clanList[indexPath.row][2]
        author = clanList[indexPath.row][3]
        
        self.selectSegue()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let heightTmp = tableView.frame.size.height / 8
        
        return  heightTmp
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectSegue" {
            
            let tabBarVC = segue.destination as! clanTabBarViewController
            tabBarVC.clanImageId = self.clanImageid
            
            let destination = (segue.destination as! clanTabBarViewController).viewControllers![0] as! ClanHomeViewController
            destination.clanId = self.clanid
            destination.clanImageId = self.clanImageid
            
            let destination2 = (segue.destination as! clanTabBarViewController).viewControllers![1] as! ClanBoardViewController
            destination2.clanid = self.clanid
            destination2.author = self.author
            
            let destination3 = (segue.destination as! clanTabBarViewController).viewControllers![2] as! ClanPhotoViewController
            destination3.clanid = self.clanid
            destination3.author = self.author
            
            let destination4 = (segue.destination as! clanTabBarViewController).viewControllers![3] as! ChatViewController
            destination4.clanid = self.clanid
            destination4.username = self.username
            destination4.userid = self.id
        }

        //        if segue.identifier == "selectSegue" {
        //            let vc = segue.destination as! clanTabBarViewController
        //            vc.clanId = self.clanId
        //
        //        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
