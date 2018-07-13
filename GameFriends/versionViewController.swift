//
//  versionViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class versionViewController: UIViewController {

    @IBOutlet weak var versionText: UILabel!
    @IBOutlet weak var versionCmpText: UILabel!
    
    var nowVersion = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionText.text = "V. \(version)"
            
            //버전 비교
            versionCmpText.text = ""
//            if nowVersion == versionText.text! {
//                versionCmpText.text = "최신버전입니다."
//            } else {
//                versionCmpText.text = "최신버전이 아닙니다."
//            }
            
        }

        // Do any additional setup after loading the view.
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/setting/version/view")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        print(parseJSON)
                    } catch {
                        print("sdafjkndsflkdshf")
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
