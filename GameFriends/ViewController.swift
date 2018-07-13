//
//  ViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData
//import SocketIO
import Firebase

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var AppNameText: UILabel!
    
    var genderList = ["Male", "Female"]
    var gender = ""
    
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var registerId: UITextField!
    @IBOutlet weak var registerPwd: UITextField!
    @IBOutlet weak var registerImageView: UIImageView!
    @IBOutlet weak var errorText: UILabel!
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerdoneButton: UIButton!
    
    var Uid = ""
    var myClanObject = [[String]]()
    
    @IBOutlet var registerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AppNameText.sizeToFit()
        loadCoreData()
//        userCheck()
        
        password2.delegate = self
        
        LoginButton.layer.masksToBounds = true
        LoginButton.layer.cornerRadius = 10
        LoginButton.layer.borderWidth = 0.4
        LoginButton.layer.borderColor = UIColor.lightGray.cgColor
        
        registerButton.layer.masksToBounds = true
        registerButton.layer.cornerRadius = 10
        registerButton.layer.borderWidth = 0.4
        registerButton.layer.borderColor = UIColor.lightGray.cgColor
        
        registerdoneButton.layer.masksToBounds = true
        registerdoneButton.layer.cornerRadius = 10
        registerdoneButton.layer.borderWidth = 0.4
        registerdoneButton.layer.borderColor = UIColor.lightGray.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
        registerImageView.isUserInteractionEnabled = true
        registerImageView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: .UIKeyboardDidHide, object: nil)
        
        errorText.text = ""
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.userCheck()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signupSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "signupSegue", sender: self)
        }
    }
    
    @objc func showActionSheet() {
        let alert = UIAlertController(title: "프로필 사진 등록", message: "사진을 등록해주세요.", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
            self.userCamera()
        })
        
        let albumAction = UIAlertAction(title: "Album", style: .default, handler: { action -> Void in
            self.useAlbum()
        })
        
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func userCamera() {
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
        
        registerImageView.image = selectedImage
    }
    
    func imageUpload() {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/uploads")
        
        let imageName = self.registerId.text! + ".jpg"
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((registerImageView.image?.resizeWithWidth(width: 100))!, 0.5)
        
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
                print("response \(response!)")
                print("dataString: \(dataString)")
            }
        })
        task.resume()
    }
    
    func loadCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                Uid = match.value(forKey: "id") as! String
                
            } else {
                print("nothing founded")
            }
        } catch {
            print("load error")
        }
    }
    
    func register() {
        var genderTmp = ""
        
        if self.gender == "Male" {
            genderTmp = "male"
        } else if self.gender == "Female" {
            genderTmp = "female"
        }
        
        let deviceId = UIDevice().identifierForVendor?.uuidString
        
        let loginUrl = URL(string: URLLib.urlObject.serverUrl + "/user/create")
        
        var request = URLRequest(url: loginUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["id" : "\(self.registerId.text!)", "password" : "\(self.registerPwd.text!)", "sex" : "\(genderTmp)", "deviceId" : "\(deviceId!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    print("Error : \((error?.localizedDescription)!)")
                } else {
                    
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        
                        let arrJSON = parseJSON["result"] as? String
                        
                        if arrJSON == "1" {
                            let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
                            let contact = Profile(entity: entityDescription!, insertInto: DBLib.coreDataLIB.managedObjectContext)
                            
                            contact.deviceId = deviceId!
                            contact.id = self.registerId.text!
                            contact.password = self.registerPwd.text!
                            contact.gender = genderTmp
                            contact.imageId = self.registerId.text! + ".jpg"
                            contact.grade = ""
                            contact.born = ""
                            contact.spot = ""
                            contact.comment = ""
                            contact.nickname = ""
                            
                            contact.hoGame1 = ""
                            contact.hoGame2 = ""
                            contact.hoGame3 = ""
                            
                            contact.battleground = false
                            contact.lineage = false
                            contact.lol = false
                            contact.overwatch = false
                            contact.etc = false
                            
                            do {
                                try DBLib.coreDataLIB.managedObjectContext.save()
                                print("success")
                            } catch {
                                print("Save error")
                            }
                            
                            self.signupSegue()
                        } else {
                            self.registError()
                            print("회원가입 에러")
                        }
                    } catch {
                        print("sadlfjndsfkdjn")
                    }
                }
            }) .resume()
        }
    }
    
    func registError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "아이디가 중복됩니다.", message: "아이디를 변경해주세요", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func loginError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "아이디 비밀번호가 일치하지 않습니다.", message: "아이디 비밀번호를 확인해주세요", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func userCheck() {
        let deviceId = UIDevice().identifierForVendor?.uuidString
        let token = Messaging.messaging().fcmToken
        
        if token == nil {
            print("token is nil")
//            print(token)
        } else {
            let checkUrl = URL(string: URLLib.urlObject.serverUrl + "/user/check")
            var request = URLRequest(url: checkUrl!)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let json = ["userid" : "\(Uid)", "deviceid" : "\(deviceId!)", "token" : "\(token!)"]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            request.httpBody = jsonData
            
            DispatchQueue.main.async {
                URLSession.shared.dataTask(with: request, completionHandler: {(data : Data?, response: URLResponse?, error: Error?) -> Void in
                    
                    if error != nil {
                        print("Error: \((error?.localizedDescription)!)")
                        
                        if error?.localizedDescription == "Could not connect to the server." {
                            let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "앱이 종료됩니다.", preferredStyle: .alert)
                            let done = UIAlertAction(title: "확인", style: .cancel, handler: { action in
                                exit(0)
                            })
                            alert.addAction(done)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        do {
                            if let httpResponse = response as? HTTPURLResponse {
                                
                            }
                            
                            let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                            
                            let check = parseJSON["result"] as! String
                            
                            if check == "1" {
                                self.signupSegue()
                            }
                        } catch {
                            print("errorrror")
                        }
                    }
                }) .resume()
            }
        }
        
        
    }
    
    func coreDataDelete() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        if let result = try? DBLib.coreDataLIB.managedObjectContext.fetch(request) {
            for object in result {
                DBLib.coreDataLIB.managedObjectContext.delete(object as! Profile)
            }
        }
    }
    
    func login() {
        
        self.coreDataDelete()
        
        let deviceId = UIDevice().identifierForVendor?.uuidString
        
        let loginUrl = URL(string: URLLib.urlObject.serverUrl + "/user/login")
        var request = URLRequest(url: loginUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["userid" : "\(self.id.text!)", "password" : "\(self.password.text!)", "deviceid" : "\(deviceId!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    print("Error : \((error?.localizedDescription)!)")
                } else {
                    DispatchQueue.main.async {
                        do {
                            let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                            
                            let arrJSON = parseJSON["result"] as? String
                            
                            if arrJSON == "2" {
                                self.loginError()
                            } else {
                                let userObject = parseJSON["result"] as! [String : AnyObject]
                                
                                var rate = userObject["rate"] as? String
                                var spot = userObject["spot"] as? String
                                var nick = userObject["nick"] as? String
                                var sex = userObject["sex"] as? String
                                var imageId = userObject["imageId"] as? String
                                var info = userObject["info"] as? String
                                var birth = userObject["birth"] as? String
                                var hoGame1 = userObject["hoGame1"] as? String
                                var hoGame2 = userObject["hoGame2"] as? String
                                var hoGame3 = userObject["hoGame3"] as? String
                                
                                imageId = self.id.text! + ".jpg"
                                if rate == nil {
                                    rate = ""
                                }
                                
                                if spot == nil {
                                    spot = ""
                                }
                                
                                if nick == nil {
                                    nick = ""
                                }
                                
                                if info == nil {
                                    info = ""
                                }
                                
                                if birth == nil {
                                    birth = ""
                                }
                                
                                if hoGame1 == nil {
                                    hoGame1 = ""
                                }
                                
                                if hoGame2 == nil {
                                    hoGame2 = ""
                                }
                                
                                if hoGame3 == nil {
                                    hoGame3 = ""
                                }
                                
                                var isBattleGround = false
                                var isLoL = false
                                var isOverWatch = false
                                var isLineage = false
                                var isEtc = false
                                
                                if hoGame1 == "배틀그라운드" {
                                    isBattleGround = true
                                } else if hoGame2 == "배틀그라운드" {
                                    isBattleGround = true
                                } else if hoGame3 == "배틀그라운드" {
                                    isBattleGround = true
                                }
                                
                                if hoGame1 == "리그오브레전드" {
                                    isLoL = true
                                } else if hoGame2 == "리그오브레전드" {
                                    isLoL = true
                                } else if hoGame3 == "리그오브레전드" {
                                    isLoL = true
                                }
                                
                                if hoGame1 == "오버워치" {
                                    isOverWatch = true
                                } else if hoGame2 == "오버워치" {
                                    isOverWatch = true
                                } else if hoGame3 == "오버워치" {
                                    isOverWatch = true
                                }
                                
                                if hoGame1 == "리니지" {
                                    isLineage = true
                                } else if hoGame2 == "리니지" {
                                    isLineage = true
                                } else if hoGame3 == "리니지" {
                                    isLineage = true
                                }
                                
                                if hoGame1 == "기타" {
                                    isEtc = true
                                } else if hoGame2 == "기타" {
                                    isEtc = true
                                } else if hoGame3 == "기타" {
                                    isBattleGround = true
                                }
                                
                                let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
                                let contact = Profile(entity: entityDescription!, insertInto: DBLib.coreDataLIB.managedObjectContext)
                                
                                contact.deviceId = deviceId!
                                contact.id = self.id.text!
                                contact.password = self.password.text!
                                contact.gender = sex
                                contact.imageId = imageId
                                contact.comment = info
                                contact.hoGame1 = hoGame1
                                contact.hoGame2 = hoGame2
                                contact.hoGame3 = hoGame3
                                contact.born = birth
                                contact.battleground = isBattleGround
                                contact.lol = isLoL
                                contact.overwatch = isOverWatch
                                contact.lineage = isLineage
                                contact.etc = isEtc
                                contact.grade = rate
                                contact.spot = spot
                                contact.nickname = nick
                                
                                do {
                                    try DBLib.coreDataLIB.managedObjectContext.save()
                                    print("success")
                                } catch {
                                    print("Save error")
                                }
                                
                                self.signupSegue()
                            }
                            
                        } catch {
                            print("errorroror")
                        }
                    }
                    
                }

            }) .resume()
        }
    }
    
    func showResgisterView() {
        registerView.frame = CGRect(x: self.view.frame.origin.x, y: (navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
        registerView.tag = 1
        
        self.view.addSubview(registerView)
    }
    
    @objc func keyboardUp(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            self.view.frame.origin.y -= keyboardFrame.size.height - 100
        }
    }
    
    @objc func keyboardDown(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == password2 {
            if registerPwd.text! != password2.text! {
                errorText.text = "비밀번호가 일치하지 않습니다."
                print("틀리다.")
            } else {
                errorText.text = ""
                print("같다.")
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("textFieldDidEndEditing")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        registerId.resignFirstResponder()
        registerPwd.resignFirstResponder()
        
        id.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        DispatchQueue.main.async {
            if let viewWithTag = self.view.viewWithTag(1) {
                viewWithTag.removeFromSuperview()
            } else {
                print("error!!")
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        
        if registerPwd.text! != password2.text! {
            errorText.text = "비밀번호가 일치하지 않습니다."
        }
        
        gender = self.genderList[self.genderSegment.selectedSegmentIndex]
    }

    @IBAction func LoginButton(_ sender: Any) {
        self.login()
    }
    
    @IBAction func registerDone(_ sender: Any) {
        if self.registerId.text! == "" || self.registerPwd.text! == "" || self.password2.text! == "" || genderSegment.selectedSegmentIndex == -1 {
            let alert = UIAlertController(title: "입력한 데이터가 정확하지 않습니다.", message: "입력값을 다시 확인해 주세요", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.register()
            self.imageUpload()
        }
    }
    
    @IBAction func registerButton(_ sender: Any) {
        self.showResgisterView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
    }
}

