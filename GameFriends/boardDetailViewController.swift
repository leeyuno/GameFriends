//
//  boardDetailViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class boardDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, replyDelegate {
    
    var clanid = ""
    var boardid = ""
    var userid = ""
    var author = ""
    
    let limitLength = 25
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var contents: UITextView!
    
    @IBOutlet weak var replyTableView: UITableView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var like: UIButton!
    @IBOutlet weak var replyView: UIView!
    
    @IBOutlet weak var boardDeleteButton: UIButton!
    
    var replyObject = [[String]]()
    var replyCount: Int!
    
    var comments = [[String]]()

    @IBOutlet weak var likeText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadBoardData()
        contents.centerVertically()
        contents.delegate = self
        
        self.boardDeleteButton.isHidden = true
        
        if self.author == self.userid {
            self.boardDeleteButton.isHidden = false
        }
        
        submit.layer.masksToBounds = true
        submit.layer.cornerRadius = 5
        submit.layer.borderColor = UIColor.darkGray.cgColor
        submit.layer.borderWidth = 0.5
        
        like.layer.masksToBounds = true
        like.layer.cornerRadius = 5
        like.layer.borderWidth = 0.5
        like.layer.borderColor = UIColor.darkGray.cgColor
        
        boardDeleteButton.layer.masksToBounds = true
        boardDeleteButton.layer.cornerRadius = 5
        boardDeleteButton.layer.borderWidth = 0.5
        boardDeleteButton.layer.borderColor = UIColor.darkGray.cgColor
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: .UIKeyboardDidHide, object: nil)
        
        let keyboardHide = UISwipeGestureRecognizer(target: self, action: #selector(keyboardHideAction))
        keyboardHide.direction = .down
        
        self.view.addGestureRecognizer(keyboardHide)
        replyView.addGestureRecognizer(keyboardHide)
        replyTableView.addGestureRecognizer(keyboardHide)
        
        replyTextField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteBoard(_ sender: Any) {
        alertDelete()
    }
    
    func deleteFunc(_ replyId: String) {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/board/del")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)", "_id" : "\(self.boardid)", "_id2" : "\(replyId)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
                
                if httpResponse.statusCode == 200 {
                    if replyId == "" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        
                        self.loadBoardData()
                    }
                }
            }
        }) .resume()
    }
    
    func alertReplyDelete(_ replyId: String) {
        let alert = UIAlertController(title: "댓글 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.deleteFunc(replyId)
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(done)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertDelete() {
        let alert = UIAlertController(title: "게시글 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.deleteFunc("")
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(done)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadBoardData() {
        replyObject.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/board/click")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "clanid" : "\(self.clanid)", "_id" : "\(self.boardid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        print(parseJSON)
                        let resultJSON = parseJSON["result"] as! [String: AnyObject]
                        
                        if resultJSON["writer"] as! String == self.userid {
                            self.boardDeleteButton.isHidden = false
                        }
                        
                        self.titleText.text = resultJSON["title"] as! String
                        self.nickname.text = resultJSON["writer_nick"] as! String
//                        self.time.text = resultJSON["created_at"] as! String
                        
                        let dateTmp = resultJSON["created_at"] as! String
                        let dateFormatter = DateFormatter()
                        let tempLocale = dateFormatter.locale
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        
                        let dateFromString = dateFormatter.date(from: dateTmp)
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        dateFormatter.locale = tempLocale
                        let stringFromDate = dateFormatter.string(from: dateFromString!)
                        
                        self.time.text = stringFromDate

                        self.contents.text = resultJSON["contents"] as! String
                        self.contents.centerVertically()
                        
                        let replyJSON = resultJSON["comments"] as! NSArray
                        
                        let likeCheck = resultJSON["like"] as? Bool
                        
                        let tmpCount = resultJSON["likeUser"] as! NSArray
                        
                        self.likeText.text = "\(tmpCount.count)명이 좋아합니다."
                        
                        if likeCheck != nil {
                            if likeCheck! == true {
                                self.like.titleLabel?.textColor = UIColor.white
                                self.like.layer.masksToBounds = true
                                //self.likeButton.layer.backgroundColor = UIColor.blue.cgColor
                                self.like.backgroundColor = UIColor(red: 0.44, green: 0.76, blue: 1.00, alpha: 1.0)
                            }
                        }
                        
                        if replyJSON.count > 0 {
                            for i in 0 ... replyJSON.count - 1 {
                                let aObject = replyJSON[i] as! [String: AnyObject]
                                
                                self.replyObject.append([aObject["name"] as! String, aObject["memo"] as! String, aObject["date"] as! String, aObject["nameimage"] as! String, aObject["_id"] as! String, aObject["name_id"] as! String])
                            }
                        }

                        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(resultJSON["writer"] as! String).jpg")
                        
                        self.imageView.downloadedFrom(url: imageUrl!)
                        self.imageView.contentMode = .scaleToFill
                        
                    } catch {
                        print("파싱데이터 캐치")
                    }
                    
                    self.configureTableView()
                }
            }
            
        }) .resume()
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "replyCell", bundle: nil)
        replyTableView.register(nib, forCellReuseIdentifier: "replyCell")
        replyTableView.delegate = self
        replyTableView.dataSource = self
        replyTableView.bounces = false
        replyTableView.reloadData()
    }
    
    @IBAction func submit(_ sender: Any) {
        replyObject.removeAll()
        
        self.replyFunc()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.loadBoardData()
//            self.configureTableView()
        }
        
        replyTextField.text = ""
        replyTextField.resignFirstResponder()
    }
    
    @IBAction func like(_ sender: Any) {
        replyObject.removeAll()
        self.likeFunc()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.loadBoardData()
        }
    }
    
    func likeFunc() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/board/like")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "boardid" : "\(self.boardid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print(response)
            }
        }) .resume()
    }
    
    func replyFunc() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/board/reply")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "boardid" : "\(self.boardid)", "memo" : "\(self.replyTextField.text!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
                
//                print(httpResponse.statusCode)
            }
            
        }) .resume()
    }
    
    @objc func keyboardHideAction() {
        replyTextField.resignFirstResponder()
    }
    
    @objc func keyboardUp(_ notification: Notification) {
        
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue) != nil {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                
                self.view.frame.origin.y = 0
                
                self.view.frame.origin.y -= keyboardHeight
                
            }
        }
    }
    
    @objc func keyboardDown(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        replyTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyObject.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! replyCell
        
        if replyObject[indexPath.row][5] == self.userid {
            cell.replyDeleteButton.isHidden = false
        } else if self.author == self.userid {
            cell.replyDeleteButton.isHidden = false
        } else {
            cell.replyDeleteButton.isHidden = true
        }
        
        cell.replyId = self.replyObject[indexPath.row][4]
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(self.replyObject[indexPath.row][3])")
        
        cell.userImage.downloadedFrom(url: imageUrl!)
        cell.userImage.contentMode = .scaleToFill
        cell.userName.text = self.replyObject[indexPath.row][0]
        cell.userMemo.text = self.replyObject[indexPath.row][1]
        
        let dateTmp = replyObject[indexPath.row][2]
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let dateFromString = dateFormatter.date(from: dateTmp)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = tempLocale
        let stringFromDate = dateFormatter.string(from: dateFromString!)
        
        cell.date.text = stringFromDate
        cell.viewName = "board"
        
        cell.replyDelegate = self
        
        return cell
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
