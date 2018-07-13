//
//  SetupViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingTableView: UITableView!
    
    let settingList = ["공지사항", "도움말", "버전정보", "개인정보처리약관"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        cell.textLabel?.text = settingList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.noticeSegue()
        } else if indexPath.row == 1 {
            self.helpSegue()
        } else if indexPath.row == 2 {
            self.versionSegue()
        } else if indexPath.row == 3 {
            self.personalData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "기본정보"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func noticeSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "noticeSegue", sender: self)
        }
    }
    
    func helpSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "helpSegue", sender: self)
        }
    }
    
    func versionSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "versionSegue", sender: self)
        }
    }
    
    func personalData() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "personalSegue", sender: self)
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
