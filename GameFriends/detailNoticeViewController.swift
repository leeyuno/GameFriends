//
//  detailNoticeViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 27..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class detailNoticeViewController: UIViewController {
    
    var noticeId = ""

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentsText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
        contentsText.centerVertically()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/setting/notice/click")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["_id" : "\(self.noticeId)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        
                        let noticeJSON = parseJSON["result"] as! [String: AnyObject]
                        print(noticeJSON)
                        self.titleText.text = noticeJSON["title"] as! String
                        self.contentsText.text = noticeJSON["text"] as! String
                        
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
