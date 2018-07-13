//
//  clanCreateViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 19..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class clanCreateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var userid = ""
    var userNick = ""
    var imageid = ""
    var subTitle = ""
    var imageName = ""
    var clanid = ""
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var spot: UITextField!
    @IBOutlet weak var name: UITextField! 
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var comment2: UITextView!
    
    @IBOutlet weak var battleground: UIButton!
    @IBOutlet weak var lol: UIButton!
    @IBOutlet weak var overwatch: UIButton!
    @IBOutlet weak var lineage: UIButton!
    @IBOutlet weak var etc: UIButton!
    
    var spotPicker = UIPickerView()
    var spotList = ["지역을 선택해주세요", "서울특별시", "경기도", "인천광역시", "부산광역시", "울산광역시", "대전광역시", "광주광역시", "제주도", "경상북도", "경상남도", "제주도", "충청북도", "충청남도", "전라북도", "전라남도", "강원도"]
    
    var selectCount = 1
    var isSelectedButton = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tap)
        
        battleground.layer.masksToBounds = true
        battleground.layer.cornerRadius = 5
//        battleground.layer.borderColor = UIColor.blue.cgColor
//        battleground.layer.borderWidth = 0.5
        
        lol.layer.masksToBounds = true
        lol.layer.cornerRadius = 5
//        lol.layer.borderColor = UIColor.blue.cgColor
//        lol.layer.borderWidth = 0.5
        
        overwatch.layer.masksToBounds = true
        overwatch.layer.cornerRadius = 5
//        overwatch.layer.borderColor = UIColor.blue.cgColor
//        overwatch.layer.borderWidth = 0.5
        
        lineage.layer.masksToBounds = true
        lineage.layer.cornerRadius = 5
//        lineage.layer.borderColor = UIColor.blue.cgColor
//        lineage.layer.borderWidth = 0.5
        
        etc.layer.masksToBounds = true
        etc.layer.cornerRadius = 5
//        etc.layer.borderColor = UIColor.blue.cgColor
//        etc.layer.borderWidth = 0.5
        
        comment2.text = "클랜설명"
        comment2.textColor = UIColor.lightGray
        comment2.delegate = self
        comment2.layer.masksToBounds = true
        comment2.layer.borderColor = UIColor.lightGray.cgColor
        comment2.layer.borderWidth = 0.25
        comment2.layer.cornerRadius = 5
        comment2.textContainer.maximumNumberOfLines = 4
        comment2.textContainer.lineBreakMode = .byTruncatingTail
        
        self.loadCoreData()
        
        spot.delegate = self
        name.delegate = self
        
        let keyboardHide = UISwipeGestureRecognizer(target: self, action: #selector(keyboardHideAction))
        keyboardHide.direction = .down
        comment2.addGestureRecognizer(keyboardHide)
        
        comment2.isUserInteractionEnabled = true
        
        let value = arc4random()
        
        imageName = userid + "\(value)" + "clan.jpg"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 10
        self.configurePickerView()
    }
    
    @objc func keyboardHideAction() {
        spot.resignFirstResponder()
        name.resignFirstResponder()
        comment.resignFirstResponder()
        comment2.resignFirstResponder()
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
        
        image.image = selectedImage
        image.contentMode = .scaleToFill
    }
    
    func loadCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            if objects.count > 0 {
                let match = objects[0] as! Profile
                userid = match.value(forKey: "id") as! String
                userNick = match.value(forKey: "nickname") as! String
                imageid = match.value(forKey: "imageId") as! String
                subTitle = match.value(forKey: "comment") as! String
            } else {
                print("nothing founded")
            }
        } catch {
            print("코어데이터 에러")
        }
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
    
    func uploadData() {
        
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/create")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.name.text!)", "author" : "\(self.userid)", "game" : "\(self.isSelectedButton)", "spot" : "\(self.spot.text!)", "subTitle" : "\(self.comment.text!)", "info" : "\(self.comment2.text!)", "imageId" : "\(self.imageName)"]
        clanid = self.name.text!

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print(response)
                    let httpResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode == 200 {
                        self.clanJoin()
                    }
                }
                
            }) .resume()
        }

    }
    
    func clanJoin() {
        print("clanJoin")
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/join")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "usernick" : "\(self.userNick)", "userid" : "\(self.userid)", "imageid" : "\(self.imageid)", "subTitle" : "\(self.subTitle)"]
        print(json)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse?.statusCode)
                }
                
            }) .resume()
        }
        
    }
    
    func uploadImage() {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((image.image?.resizeWithWidth(width: 400))!, 1.0)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let mimetype = "image/*"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"; filename=\"\(imageName)\"\r\n".data(using: String.Encoding.utf8)!)
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
                print("이미지 업로드 성공")
//                print("response \(response!)")
//                print("dataString: \(dataString)")
            }
        })
        task.resume()
    }
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBAction func createButton(_ sender: Any) {
        if battleground.isSelected {
            isSelectedButton = "배틀그라운드"
        } else if lol.isSelected {
            isSelectedButton = "리그오브레전드"
        } else if overwatch.isSelected {
            isSelectedButton = "오버워치"
        } else if lineage.isSelected {
            isSelectedButton = "리니지"
        } else if etc.isSelected {
            isSelectedButton = "기타"
        }
        
        if name.text! == "" || spot.text! == "" || spot.text! == "지역을 선택해주세요" || comment.text! == "" || comment2.text! == "" || isSelectedButton == "" || image.image == UIImage(named: "add-image") {
            let alert = UIAlertController(title: "입력정보 오류", message: "입력값을 확인해주세요", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.uploadData()
            self.uploadImage()
            
            self.image.image = nil
            self.spot.text = ""
            self.name.text = ""
            self.comment.text = ""
            self.comment2.text = ""
            self.battleground.isSelected = false
            self.lol.isSelected = false
            self.lineage.isSelected = false
            self.overwatch.isSelected = false
            self.etc.isSelected = false
            
            self.createSuccess()
        }
    }
    
    func createSuccess() {
        let alert = UIAlertController(title: "클랜생성에 성공했습니다.", message: "클랜생성에 성공했습니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            self.doneAction()
        })
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func doneAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func battleground(_ sender: Any) {
        if battleground.isSelected {
            battleground.isSelected = false
            selectCount += 1
        } else {
            if selectCount == 0 {
                let alert = UIAlertController(title: "게임 선택 오류", message: "클랜의 게임은 한개만 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(done)
                present(alert, animated: true, completion: nil)
            } else {
                battleground.isSelected = true
                selectCount -= 1
            }
        }
    }
    
    @IBAction func lol(_ sender: Any) {
        if lol.isSelected {
            lol.isSelected = false
            selectCount += 1
        } else {
            if selectCount == 0 {
                let alert = UIAlertController(title: "게임 선택 오류", message: "클랜의 게임은 한개만 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(done)
                present(alert, animated: true, completion: nil)
            } else {
                lol.isSelected = true
                selectCount -= 1
            }
        }
    }
    
    @IBAction func overwatch(_ sender: Any) {
        if overwatch.isSelected {
            overwatch.isSelected = false
            selectCount += 1
        } else {
            if selectCount == 0 {
                let alert = UIAlertController(title: "게임 선택 오류", message: "클랜의 게임은 한개만 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(done)
                present(alert, animated: true, completion: nil)
            } else {
                overwatch.isSelected = true
                selectCount -= 1
            }
        }
    }

    @IBAction func lineage(_ sender: Any) {
        if lineage.isSelected {
            lineage.isSelected = false
            selectCount += 1
        } else {
            if selectCount == 0 {
                let alert = UIAlertController(title: "게임 선택 오류", message: "클랜의 게임은 한개만 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(done)
                present(alert, animated: true, completion: nil)
            } else {
                lineage.isSelected = true
                selectCount -= 1
            }
        }
    }
    
    @IBAction func etc(_ sender: Any) {
        if etc.isSelected {
            etc.isSelected = false
            selectCount += 1
        } else {
            if selectCount == 0 {
                let alert = UIAlertController(title: "게임 선택 오류", message: "클랜의 게임은 한개만 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(done)
                present(alert, animated: true, completion: nil)
            } else {
                etc.isSelected = true
                selectCount -= 1
            }
        }
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "클랜설명" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spot.resignFirstResponder()
        name.resignFirstResponder()
        comment.resignFirstResponder()
        comment2.resignFirstResponder()
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        print("2")
//        textView.text = ""
//        textView.textColor = UIColor.black
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "클랜설명"
            textView.textColor = UIColor.lightGray
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
