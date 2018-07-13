//
//  detailHelpViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 27..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class detailHelpViewController: UIViewController {
    
    var helpId = ""

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
        let url = URL(string: URLLib.urlObject.serverUrl + "/setting/help/click")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["_id" : "\(self.helpId)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        let helpJSON = parseJSON["result"] as! [String: AnyObject]
                        
                        self.titleText.text = helpJSON["title"] as! String
                        self.contentsText.text = helpJSON["text"] as! String
                    } catch {
                        print("help/click try catch")
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
