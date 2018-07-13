//
//  uploadBoardViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 8..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class uploadBoardViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var userid = ""
    var clanid = ""
    var noticeisSelected = ""
    var author = ""

    @IBOutlet weak var noticeButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contents: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        uploadButton.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = 10
        
        contents.text = "내용을 입력해주세요"
        contents.textColor = UIColor.lightGray
        contents.layer.masksToBounds = true
        contents.layer.cornerRadius = 5
        contents.layer.borderColor = UIColor.lightGray.cgColor
        contents.layer.borderWidth = 0.5
        
        contents.delegate = self
        titleText.delegate = self
        contents.delegate = self
        
        noticeButton.layer.masksToBounds = true
        noticeButton.layer.borderColor = UIColor.lightGray.cgColor
        noticeButton.layer.borderWidth = 0.3
        noticeButton.layer.cornerRadius = 10
        
        let keyboardHide = UISwipeGestureRecognizer(target: self, action: #selector(keyboardHideAction))
        keyboardHide.direction = .down
        
        titleText.addGestureRecognizer(keyboardHide)
        contents.addGestureRecognizer(keyboardHide)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardHideAction() {
        titleText.resignFirstResponder()
        contents.resignFirstResponder()
    }
    
    func uploadBoard() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/board/upload")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "clanid" : "\(self.clanid)", "title" : "\(self.titleText.text!)", "content" : "\(self.contents.text!)", "cc" : "\(noticeisSelected)"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let httpResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode == 200 {
                        self.uploadAlert()
                    }
                }
            }
        }) .resume()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = "내용을 입력해주세요"
            textView.textColor = UIColor.lightGray
        }
        return true
    }
    
    func uploadAlert() {
        let alert = UIAlertController(title: "업로드에 성공했습니다.", message: "업로드에 성공했습니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            self.backAction()
        })
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func keyboardUp(_ notification: Notification) {
        
    }
    
    func keyboardDown(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue) != nil {
            
        }
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    @IBAction func noticeButton(_ sender: Any) {
        
        if self.author == self.userid {
            if noticeButton.isSelected {
                noticeButton.isSelected = false
                noticeButton.layer.backgroundColor = UIColor.clear.cgColor
                noticeButton.titleLabel?.textColor = UIColor.blue
                noticeisSelected = ""
            } else {
                noticeButton.isSelected = true
                //noticeButton.backgroundColor = UIColor.blue
                //            noticeButton.backgroundColor = UIColor(red: 0.44, green: 0.76, blue: 1.00, alpha: 1.0)
                noticeButton.titleLabel?.textColor = UIColor.white
                noticeisSelected = "true"
            }
        } else {
            let alert = UIAlertController(title: "공지사항을 업로드할 수 없습니다.", message: "관리자만 공지사항 업로드가 가능합니다.", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        if titleText.text! == "" || contents.text! == "" {
            let alert = UIAlertController(title: "입력하신 값이 정확하지 않습니다.", message: "입력값을 확인해주세요.", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.uploadBoard()
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
