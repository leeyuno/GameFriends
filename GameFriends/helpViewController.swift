//
//  helpViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class helpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var helpTable: UITableView!
    var helpObject = [[String]]()
    var helpId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "settingCell", bundle: nil)

        helpTable.register(nib, forCellReuseIdentifier: "settingCell")
        helpTable.delegate = self
        helpTable.dataSource = self
        helpTable.bounces = false
        helpTable.reloadData()
    }
    
    func loadData() {
        helpObject.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/setting/help/view")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        
                        let checkJSON = parseJSON["result"] as? String
                        
                        if checkJSON == "2" {
                            // 데이터가 없음
                        } else if checkJSON == "0" {
                            // 데이터가 없음
                        } else {
                            let arrJSON = parseJSON["result"] as! NSArray
                            print(arrJSON)
                            for i in 0 ... arrJSON.count - 1 {
                                let noticeArray = arrJSON[i] as! [String : AnyObject]
                                
                                self.helpObject.append([noticeArray["title"] as! String, noticeArray["text"] as! String, noticeArray["created_at"] as! String, noticeArray["_id"] as! String])
                            }
                            
                        }
                        self.configureTableView()
                    } catch {
                        print("노티스 파싱 캐치")
                    }
                }
            }
        }) .resume()
    }
    
    func helpSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "helpSegue", sender: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpObject.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height / 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        helpId = helpObject[indexPath.row][3]
        self.helpSegue()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! settingCell
        
        let dateTmp = helpObject[indexPath.row][2]
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let dateFromString = dateFormatter.date(from: dateTmp)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = tempLocale
        let stringFromDate = dateFormatter.string(from: dateFromString!)
        
        cell.titleText.text = helpObject[indexPath.row][0]
        cell.dateText.text = stringFromDate
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "helpSegue" {
            let vc = segue.destination as! detailHelpViewController
            vc.helpId = self.helpId
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
