//
//  clanDataUpdateViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class clanDataUpdateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    var clanid = ""
    var userid = ""
    var game = ""

    @IBOutlet weak var clanImage: UIImageView!
    @IBOutlet weak var spot: UITextField!
    @IBOutlet weak var clanName: UITextField!
    @IBOutlet weak var clanComment: UITextField!
    @IBOutlet weak var clanComment2: UITextView!
    
    var tmpClanComment = ""
    var tmpClanComment2 = ""
    var tmpClanSpot = ""
    var tmpClanImage = ""
    var tmpClanName = ""
    
    var gameSelected = 1
    
    @IBOutlet weak var battleGround: UIButton!
    @IBOutlet weak var lol: UIButton!
    @IBOutlet weak var overWatch: UIButton!
    @IBOutlet weak var lineage: UIButton!
    @IBOutlet weak var etc: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var spotPicker = UIPickerView()
    var spotList = ["상관없음", "서울특별시", "경기도", "인천광역시", "부산광역시", "울산광역시", "대전광역시", "광주광역시", "제주도", "경상북도", "경상남도", "제주도", "충청북도", "충청남도", "전라북도", "전라남도", "강원도"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if game == "배틀그라운드" {
            battleGround.isSelected = true
        } else if game == "리그오브레전드" {
            lol.isSelected = true
        } else if game == "오버워치" {
            overWatch.isSelected = true
        } else if game == "리니지" {
            lineage.isSelected = true
        } else if game == "기타" {
            etc.isSelected = true
        }
        
        spot.delegate = self
        clanName.delegate = self
        clanComment2.delegate = self
        clanComment.delegate = self
        
        spot.text = tmpClanSpot
        clanName.text = tmpClanName
        clanComment.text = tmpClanComment
        clanComment2.text = tmpClanComment2
        
        clanImage.layer.masksToBounds = true
        clanImage.layer.borderColor = UIColor.black.cgColor
        clanImage.layer.borderWidth = 0.5
        clanImage.layer.cornerRadius = 10
        
        clanComment2.layer.masksToBounds = true
        clanComment2.layer.borderWidth = 0.3
        clanComment2.layer.borderColor = UIColor.lightGray.cgColor
        clanComment2.layer.cornerRadius = 5
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_download/\(self.tmpClanImage)")
        clanImage.downloadedFrom(url: imageUrl!)
        clanImage.contentMode = .scaleToFill
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
        clanImage.isUserInteractionEnabled = true
        clanImage.addGestureRecognizer(tap)
        
        let keyboardHide = UISwipeGestureRecognizer(target: self, action: #selector(keyboardHideAction))
        keyboardHide.direction = .down
        
        self.view.addGestureRecognizer(keyboardHide)
        
        self.configurePickerView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardHideAction() {
        clanName.resignFirstResponder()
        clanComment.resignFirstResponder()
        clanComment2.resignFirstResponder()
    }
    
    @objc func showActionSheet() {
        let alert = UIAlertController(title: "프로필 사진 등록", message: "프로필에 사용할 사진을 등록해주세요", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
            self.useCamera()
        })
        
        let albumAction = UIAlertAction(title: "Album", style: .default, handler: { action -> Void in
            self.useAlbum()
        })
        
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func useCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        self.show(picker, sender: nil)
    }
    
    func useAlbum() {
        let picker = UIImagePickerController()
        picker.delegate = self
        self.show(picker, sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        clanImage.image = selectedImage
        clanImage.contentMode = .scaleToFill
    }
    
    func configurePickerView() {
        spotPicker.delegate = self
        spot.inputView = spotPicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let done = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(donePressed(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelPressed(_:)))
        
        toolBar.setItems([cancel, space, done], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        spot.inputAccessoryView = toolBar
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        spot.resignFirstResponder()
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem) {
        spot.text = ""
        spot.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return spotList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        spot.text = spotList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return spotList.count
    }
    
    @IBAction func battleGround(_ sender: Any) {
        
        if battleGround.isSelected {
            battleGround.isSelected = false
            gameSelected -= 1
        } else {
            if gameSelected == 1 {
                let alert = UIAlertController(title: "게임선택에러", message: "대표게임은 하나만 선택해주세요.", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            } else if gameSelected == 0 {
                battleGround.isSelected = true
                gameSelected += 1
            }
        }
    }
    @IBAction func lol(_ sender: Any) {
        if lol.isSelected {
            lol.isSelected = false
            gameSelected -= 1
        } else {
            if gameSelected == 1 {
                let alert = UIAlertController(title: "게임선택에러", message: "대표게임은 하나만 선택해주세요.", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            } else if gameSelected == 0 {
                lol.isSelected = true
                gameSelected += 1
            }
        }
    }
    @IBAction func overWatch(_ sender: Any) {
        if overWatch.isSelected {
            overWatch.isSelected = false
            gameSelected -= 1
        } else {
            if gameSelected == 1 {
                let alert = UIAlertController(title: "게임선택에러", message: "대표게임은 하나만 선택해주세요.", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            } else if gameSelected == 0 {
                overWatch.isSelected = true
                gameSelected += 1
            }
        }
    }
    @IBAction func lineage(_ sender: Any) {
        if lineage.isSelected {
            lineage.isSelected = false
            gameSelected -= 1
        } else {
            if gameSelected == 1 {
                let alert = UIAlertController(title: "게임선택에러", message: "대표게임은 하나만 선택해주세요.", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            } else if gameSelected == 0 {
                lineage.isSelected = true
                gameSelected += 1
            }
        }
    }
    @IBAction func etc(_ sender: Any) {
        if etc.isSelected {
            etc.isSelected = false
            gameSelected -= 1
        } else {
            if gameSelected == 1 {
                let alert = UIAlertController(title: "게임선택에러", message: "대표게임은 하나만 선택해주세요.", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            } else if gameSelected == 0 {
                etc.isSelected = true
                gameSelected += 1
            }
        }
    }
    
    func uploadData() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/update")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var tmpGame = ""
        
        if battleGround.isSelected {
            tmpGame = "배틀그라운드"
        } else if lol.isSelected {
            tmpGame = "리그오브레전드"
        } else if overWatch.isSelected {
            tmpGame = "오버워치"
        } else if lineage.isSelected {
            tmpGame = "리니지"
        } else if etc.isSelected {
            tmpGame = "기타"
        }
        
        let json = ["clanid" : "\(self.clanid)", "author" : "\(self.userid)", "game" : "\(tmpGame)", "spot" : "\(self.spot.text!)", "imageId" : "\(self.tmpClanImage)", "subTitle" : "\(self.clanComment.text!)", "info" : "\(self.clanComment2.text!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
                
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                         let alert = UIAlertController(title: "성공", message: "클랜정보 수정에 성공했습니다.", preferredStyle: .alert)
                        let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                        
                        alert.addAction(done)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                print(response)
            }
        }) .resume()
    }
    
    func uploadImage() {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((clanImage.image?.resizeWithWidth(width: 300))!, 1.0)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let mimetype = "image/*"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"; filename=\"\(tmpClanImage)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData!)
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard ((data) != nil), let _:URLResponse = response, error == nil else {
                print("error \(error!)")
                return
            }
            
            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                print("response \(response!)")
                print("dataString: \(dataString)")
            }
        })
        task.resume()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.uploadData()
        self.uploadImage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        clanName.resignFirstResponder()
        clanComment.resignFirstResponder()
        clanComment2.resignFirstResponder()
        spot.resignFirstResponder()
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
 

}
