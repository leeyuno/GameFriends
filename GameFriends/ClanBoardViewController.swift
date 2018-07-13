//
//  ClanBoardViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class ClanBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var boardTable: UITableView!
    
    var userid = ""
    var clanid = ""
    var author = ""
    var boardid = ""
    
    var boardObject = [[String]]()
    var sortObejct = [[String]]()

    @IBOutlet weak var uploadButton: UIButton!
    
    var reFreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                userid = match.value(forKey: "id") as! String
            } else {
                print("nothing founded")
            }
        } catch {
            print("coredata error")
        }
        
        self.loadBoardData()
        
        reFreshControl = UIRefreshControl()
        reFreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        reFreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        boardTable.addSubview(reFreshControl)
        
        uploadButton.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = self.uploadButton.frame.size.height / 2
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @objc func refresh(_ sender: Any) {
        print("PULL TO REFRESH")
        self.loadBoardData()
        reFreshControl.endRefreshing()
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "boardCell", bundle: nil)
        boardTable.register(nib, forCellReuseIdentifier: "boardCell")

        let nib2 = UINib(nibName: "noticeCell", bundle: nil)
        boardTable.register(nib2, forCellReuseIdentifier: "noticeCell")
        
        boardTable.delegate = self
        boardTable.dataSource = self
        
        boardTable.reloadData()
        
    }
    
    func loadBoardData() {
        boardObject.removeAll()
        sortObejct.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/board/view")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "clanid" : "\(self.clanid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        let arrJSON = parseJSON["result"] as? NSArray
            
                        if arrJSON == nil {
                            let alert = UIAlertController(title: "게시판이 비어있습니다.", message: "게시글을 등록해주세요", preferredStyle: .alert)
                            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                            
                            alert.addAction(done)
                            
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            if (arrJSON?.count)! > 0 {
                                for i in 0 ... (arrJSON?.count)! - 1 {
                                    let boardItem = arrJSON?[i] as! [String : AnyObject]
                                    if boardItem["adminCheck"] as! Bool == true {
                                        let dateTmp = boardItem["created_at"] as! String
                                        let dateFormatter = DateFormatter()
                                        let tempLocale = dateFormatter.locale
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        
                                        let dateFromString = dateFormatter.date(from: dateTmp)
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        dateFormatter.locale = tempLocale
                                        let stringFromDate = dateFormatter.string(from: dateFromString!)
                                        
                                        self.sortObejct.append([boardItem["title"] as! String, boardItem["contents"] as! String, boardItem["writer"] as! String, stringFromDate, String(boardItem["adminCheck"] as! Bool), boardItem["_id"] as! String, boardItem["writer_nick"] as! String])
                                    }
                                }
                                
                                for i in 0 ... (arrJSON?.count)! - 1 {
                                    let boardItem = arrJSON?[i] as! [String : AnyObject]
                                    if boardItem["adminCheck"] as! Bool == false {
                                        let dateTmp = boardItem["created_at"] as! String
                                        let dateFormatter = DateFormatter()
                                        let tempLocale = dateFormatter.locale
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        
                                        let dateFromString = dateFormatter.date(from: dateTmp)
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        dateFormatter.locale = tempLocale
                                        let stringFromDate = dateFormatter.string(from: dateFromString!)
                                        
                                        self.boardObject.append([boardItem["title"] as! String, boardItem["contents"] as! String, boardItem["writer"] as! String, stringFromDate, String(boardItem["adminCheck"] as! Bool), boardItem["_id"] as! String, boardItem["writer_nick"] as! String])
                                    }
                                }
                            }
                            self.sortTable()
                            self.sortObejct.append(contentsOf: self.boardObject)
                        }
                        self.configureTableView()
                    } catch {
                        print("catch")
                    }
                }
            }
        }) .resume()
    }
    
//    func dateSorting() {
//        var dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//
//        for _ in 0 ... boardObject.count - 1 {
//            let sort = boardObject.sorted(by: { $0[3]})
//        }
//    }
    
    func sortTable() {
        if boardObject.count > 0 {
            for i in 0 ... boardObject.count - 1 {
                let sort = boardObject.sorted(by: { $0[3] > $1[3] })
                self.boardObject = sort
            }
        }
    }
    
    func boardSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "boardSegue", sender: self)
        }
    }
    
    func boardDetailSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "boardDetailSegue", sender: self)
        }
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        self.boardSegue()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortObejct.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if sortObejct[indexPath.row][4]  == "true" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! noticeCell
            
            cell.title.text = sortObejct[indexPath.row][0]
            cell.contents.text = sortObejct[indexPath.row][1]
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell", for: indexPath) as! boardCell
            
            let imageName = sortObejct[indexPath.row][2] + ".jpg"
            
            let url = URL(string: URLLib.urlObject.serverUrl + "/download/\(imageName)")
            
            cell.boardNick.text = sortObejct[indexPath.row][6]
            cell.boardTitle.text = sortObejct[indexPath.row][0]
            cell.boardTime.text = sortObejct[indexPath.row][3]
            //cell.boardContents.text = sortObejct[indexPath.row][1]
            cell.boardImage.downloadedFrom(url: url!)
            cell.boardImage.contentMode = .scaleToFill
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.boardid = sortObejct[indexPath.row][5]
        
        self.boardDetailSegue()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "boardSegue" {
            let destination = segue.destination as! uploadBoardViewController
            destination.clanid = self.clanid
            destination.userid = self.userid
            destination.author = self.author
        } else if segue.identifier == "boardDetailSegue" {
            let destination = segue.destination as! boardDetailViewController
            destination.clanid = self.clanid
            destination.author = self.author
            destination.boardid = self.boardid
            destination.userid = self.userid
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
