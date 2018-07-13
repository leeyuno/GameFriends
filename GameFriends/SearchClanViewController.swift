//
//  SearchClanViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class SearchClanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var spot = ""
    var hoGame1 = ""
    var hoGame2 = ""
    var hoGame3 = ""
    
    var clanId = ""
    var clanImageId = ""
    var memberCount = ""
    var author = ""
    
    var reFreshControl: UIRefreshControl!
    
    //클랜데이터를 클랜홈으로 전달하기위한 함수
    var clanArray = [[String]]()
    var memberObject: NSArray!
    var memberArray = [[NSArray]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.showsCancelButton = true

        searchBar.delegate = self
        searchBar.placeholder = "클랜 상세 검색"
        
        reFreshControl = UIRefreshControl()
        reFreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        reFreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(reFreshControl)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.loadCoreData()
        
        if self.spot == "" || self.hoGame1 == "" || self.hoGame2 == "" || self.hoGame3 == "" {
            let alert = UIAlertController(title: "프로필을 작성해주세요.", message: "유저 프로필 작성을 완료해주세요.", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.findClan()
//            self.configureTableView()
//            self.loadCoreData()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                self.findClan()
//                self.configureTableView()
//            }
        }

        //self.tableView.reloadData()
    }
    
    @objc func refresh(_ sender: Any) {
        print("PULL TO REFRESH")
        findClan()
        reFreshControl.endRefreshing()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchClan()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.findClan()
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "myClanCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myClanCell")
        tableView.tableFooterView = UIView()
//        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
    
    func loadCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                spot = match.value(forKey: "spot") as! String
                hoGame1 = match.value(forKey: "hoGame1") as! String
                hoGame2 = match.value(forKey: "hoGame2") as! String
                hoGame3 = match.value(forKey: "hoGame3") as! String
            }
            
        } catch {
            print("erererer")
        }
    }
    
    func searchClan() {
        clanArray.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/find/detail")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["text" : "\(self.searchBar.text!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    
                    let arrJSON = parseJSON["result"] as? NSArray
                    
                    if (arrJSON?.count)! > 0 {
                        for i in 0 ... (arrJSON?.count)! - 1 {
                            let clanObject = arrJSON?[i] as! [String : AnyObject]
                            
                            self.clanArray.append([clanObject["id"] as! String, clanObject["info"] as! String, clanObject["game"] as! String, clanObject["author"] as! String, clanObject["spot"] as! String, clanObject["subTitle"] as! String, clanObject["imageId"] as! String])
                            
                            self.memberObject = clanObject["member"] as! NSArray
                            
                            var Ccount = 0
                            
                            if self.memberObject.count > 0 {
                                for i in 0 ... self.memberObject.count - 1 {
                                    let aObject = self.memberObject[i] as! [String : AnyObject]
                                    
                                    if aObject["check"] as! Bool == true {
                                        
                                        Ccount += 1
                                    }
                                }
                            }
                            self.memberCount = String(self.memberObject.count)
                            self.clanArray[i].append(String(Ccount))
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.configureTableView()
                            }
                        }
                    }
                } catch {
                    print("searchclan error")
                }
            }
        }) .resume()
    }
    
    func findClan() {
        clanArray.removeAll()
        
        let clanUrl = URL(string: URLLib.urlObject.serverUrl + "/clan/find")
        var request = URLRequest(url: clanUrl!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["hoGame1" : "\(self.hoGame1)", "hoGame2" : "\(self.hoGame2)", "hoGame3" : "\(self.hoGame3)", "spot" : "\(self.spot)"]
        
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
                            let alert = UIAlertController(title: "클랜이 존재하지 않습니다.", message: "클랜을 최초로 생성해주세요.", preferredStyle: .alert)
                            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                            
                            alert.addAction(done)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let clanList = parseJSON["result"] as? NSArray
                            if (clanList?.count)! > 0 {
                                for i in 0 ... (clanList?.count)! - 1 {
                                    let clanObject = clanList?[i] as! [String : AnyObject]
                                    
                                    self.clanArray.append([clanObject["id"] as! String, clanObject["info"] as! String, clanObject["game"] as! String, clanObject["author"] as! String, clanObject["spot"] as! String, clanObject["subTitle"] as! String, clanObject["imageId"] as! String])
                                    
                                    self.memberObject = clanObject["member"] as! NSArray
                                    
                                    var Ccount = 0
                                    
                                    if self.memberObject.count > 0 {
                                        for i in 0 ... self.memberObject.count - 1 {
                                            let aObject = self.memberObject[i] as! [String : AnyObject]
                                            
                                            if aObject["check"] as! Bool == true {
                                                
                                                Ccount += 1
                                            }
                                        }
                                    }
                                    
                                    self.memberCount = String(self.memberObject.count)
                                    self.clanArray[i].append(String(Ccount))

                                    self.configureTableView()
                                }
                            }
                        }
                    } catch {
                        print("erroreorier")
                    }
                }
            }
            
        }) .resume()
    }
    
    func clanNothing() {
        let alert = UIAlertController(title: "클랜이 존재하지 않습니다.", message: "첫번째로 클랜을 만들어 보세요.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.clanArray.count > 0 {
            return self.clanArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        clanId = clanArray[indexPath.row][0]
        author = clanArray[indexPath.row][3]
        clanImageId = clanArray[indexPath.row][6]
//        clanData = clanArray[indexPath.row]
//        memberData = memberArray[indexPath.row]
        
        self.selectSegue()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "myClanCell", for: indexPath) as! myClanCell
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_download/\(self.clanArray[indexPath.row][6])")
        cell.clanImage.downloadedFrom(url: imageUrl!)
        cell.clanImage.contentMode = .scaleToFill
        
        cell.clanName.text = self.clanArray[indexPath.row][0]
        cell.clanComment.text = self.clanArray[indexPath.row][5]
        cell.clanUser.text = self.clanArray[indexPath.row][7] + "명"
        
//        cell.clanName.text = clanArray[indexPath.row][0]
//        cell.clanComment.text = clanArray[indexPath.row][5]
//        cell.number.text = clanArray[indexPath.row][7] + "명"
        
        return cell
    }
    
    func selectSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "selectSegue", sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "selectSegue" {
            
            let tabVC = segue.destination as! clanTabBarViewController
            tabVC.clanId = self.clanId
            tabVC.clanImageId = self.clanImageId
            
            let destination = (segue.destination as! clanTabBarViewController).viewControllers![0] as! ClanHomeViewController
            destination.clanId = self.clanId
            destination.clanImageId = self.clanImageId
            
            let destination2 = (segue.destination as! clanTabBarViewController).viewControllers![1] as! ClanBoardViewController
            destination2.clanid = self.clanId
            destination2.author = self.author
            
            let destination3 = (segue.destination as! clanTabBarViewController).viewControllers![2] as! ClanPhotoViewController
            destination3.clanid = self.clanId
            
            let destination4 = (segue.destination as! clanTabBarViewController).viewControllers![3] as! ChatViewController
            destination4.clanid = self.clanId
        }
        
        
//        if segue.identifier == "selectSegue" {
//            let vc = segue.destination as! clanTabBarViewController
//            vc.clanId = self.clanId
//
//        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
