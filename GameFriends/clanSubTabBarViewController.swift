//
//  clanSubTabBarViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class clanSubTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "돌아가기", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.rightBarButtonItem = backButton
        
        self.navigationItem.hidesBackButton = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
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
