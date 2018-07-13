//
//  HomeViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil}
        UIGraphicsEndImageContext()
        return result
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    //게임선택 버튼
    @IBOutlet weak var BattleGround: UIButton!
    @IBOutlet weak var LeagueOfLegend: UIButton!
    @IBOutlet weak var OverWatch: UIButton!
    @IBOutlet weak var Lineage: UIButton!
    @IBOutlet weak var Etc: UIButton!
    
    //프로필
    @IBOutlet weak var gender: UISegmentedControl!
    var genderList = ["남자", "여자"]
    var genderValue = ""
    
    var id = ""
    var hoGame1 = ""
    var hoGame2 = ""
    var hoGame3 = ""
    var genderTmp = ""
    var imageId = ""
    
    var maximum = 3
    let limitLength = 15
    
    @IBOutlet weak var ProfileImage: UIImageView!
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var Nickname: UITextField!
    @IBOutlet weak var Grade: UITextField!
    @IBOutlet weak var Born: UITextField!
    @IBOutlet weak var spot: UITextField!
    @IBOutlet weak var Comment: UITextField!
    @IBOutlet weak var gameId: UITextField!
    
    var isEditingProfile = true
    
    var spotPicker = UIPickerView()
    var spotList = ["서울특별시", "경기도", "인천광역시", "부산광역시", "울산광역시", "대전광역시", "광주광역시", "제주도", "경상북도", "경상남도", "제주도", "충청북도", "충청남도", "전라북도", "전라남도", "강원도"]
    
    @IBOutlet weak var switchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileImage.layer.borderColor = UIColor.lightGray.cgColor
        ProfileImage.layer.borderWidth = 0.4
        ProfileImage.isUserInteractionEnabled = true
        ProfileImage.layer.masksToBounds = true
        ProfileImage.layer.cornerRadius = 10

        
        //텍스트필드, 이미지가 수정되지 않도록 세팅하는 함수
        self.defaultSetting()
        
        //pickerView 세팅 함수
        self.configurePickerView()
        
        //사용자가 아직 입력하지 않은 데이터가 있으면 placeholder를 만드는 함수
        
        loadCoreData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: .UIKeyboardDidHide, object: nil)
        
        switchButton.layer.masksToBounds = true
        switchButton.layer.cornerRadius = 5
        switchButton.layer.borderWidth = 0.4
        switchButton.layer.borderColor = UIColor.lightGray.cgColor

        Nickname.delegate = self
        spot.delegate = self
        Comment.delegate = self
        Born.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func loadCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                self.gameId.text = match.value(forKey: "id") as! String
                genderTmp = match.value(forKey: "gender") as! String
                self.Grade.text = match.value(forKey: "grade") as? String
                self.Nickname.text = match.value(forKey: "nickname") as? String
                self.Born.text = match.value(forKey: "born") as? String
                //self.genderValue = match.value(forKey: "gender") as! String
                self.spot.text = match.value(forKey: "spot") as? String
                self.Comment.text = match.value(forKey: "comment") as? String
                self.imageId = match.value(forKey: "imageId") as! String
                
                self.hoGame1 = match.value(forKey: "hoGame1") as! String
                self.hoGame2 = match.value(forKey: "hoGame2") as! String
                self.hoGame3 = match.value(forKey: "hoGame3") as! String
                
                if genderTmp == "male" {
                    gender.selectedSegmentIndex = 0
                } else if genderTmp == "female" {
                    gender.selectedSegmentIndex = 1
                }

                self.BattleGround.isSelected = match.value(forKey: "battleground") as! Bool
                self.LeagueOfLegend.isSelected = match.value(forKey: "lol") as! Bool
                self.OverWatch.isSelected = match.value(forKey: "overwatch") as! Bool
                self.Lineage.isSelected = match.value(forKey: "lineage") as! Bool
                self.Etc.isSelected = match.value(forKey: "etc") as! Bool
                
                let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(imageId)")
                
                let data = NSData(contentsOf: imageUrl!)
                ProfileImage.image = UIImage(data: data! as Data)

                if self.BattleGround.isSelected{
                    maximum -= 1
                }
                
                if self.LeagueOfLegend.isSelected {
                    maximum -= 1
                }
                
                if self.OverWatch.isSelected {
                    maximum -= 1
                }
                
                if self.Lineage.isSelected {
                    maximum -= 1
                }
                
                if self.Etc.isSelected {
                    maximum -= 1
                }
                
                if genderTmp == "male" {
                    gender.selectedSegmentIndex = 0
                } else if genderTmp == "female" {
                    gender.selectedSegmentIndex = 1
                }
                
                self.emptyCheck()
                
            } else {
                print("nothing founded")
            }
        } catch {
            print("load error")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesBackButton = true
        //        navigationController?.navigationBar.topItem?.title = "내정보"
    }
    
    @objc func datePickerValueChaned(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        Born.text = dateFormatter.string(from: sender.date)
    }
    
    func emptyCheck() {
        if self.Grade.text == "" {
            self.Grade.placeholder = "등급"
            self.Grade.adjustsFontSizeToFitWidth = true
            self.Grade.adjustsFontForContentSizeCategory = true
            self.Grade.minimumFontSize = 10.0
            
        }
        
        if self.Nickname.text == "" {
            self.Nickname.placeholder = "닉네임"
            self.Nickname.adjustsFontSizeToFitWidth = true
            self.Nickname.sizeToFit()
        }
        
        if self.Born.text == "" {
            self.Born.placeholder = "생년월일"
            self.Born.adjustsFontSizeToFitWidth = true
            self.Born.sizeToFit()
        }
        
        if self.spot.text == "" {
            self.spot.placeholder = "지역"
            self.spot.adjustsFontSizeToFitWidth = true
            self.spot.sizeToFit()
        }
        
        if self.Comment.text == "" {
            self.Comment.placeholder = "자기소개"
            self.Comment.adjustsFontSizeToFitWidth = true
            self.Comment.sizeToFit()
        }
    }
    
    func defaultSetting() {
        ProfileImage.removeGestureRecognizer(tap)
        
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
        
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        Born.inputView = datePickerView
        Born.inputAccessoryView = toolBar
        datePickerView.addTarget(self, action: #selector(datePickerValueChaned(_:)), for: .valueChanged)
        
        Nickname.isEnabled = false
        Grade.isEnabled = false
        //Name.isEnabled = false
        gameId.isEnabled = false
        spot.isEnabled = false
        Born.isEnabled = false
        gender.isEnabled = false
        Comment.isEnabled = false
        
        BattleGround.isEnabled = false
        LeagueOfLegend.isEnabled = false
        OverWatch.isEnabled = false
        Lineage.isEnabled = false
        Etc.isEnabled = false
        
        BattleGround.sizeToFit()
        Lineage.sizeToFit()
        OverWatch.sizeToFit()
        LeagueOfLegend.sizeToFit()
        Etc.sizeToFit()
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
        Born.resignFirstResponder()
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem) {
        spot.text = ""
        spot.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func valueChanged(_ sender: Any) {
//        genderValue = self.genderList[gender.selectedSegmentIndex]
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return spotList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return spotList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        spot.text = spotList[row]
    }
    
    @IBAction func switchButton(_ sender: Any) {
        
        if isEditingProfile {
            isEditingProfile = false
            switchButton.setTitle("완료", for: .normal)
            
            Nickname.isEnabled = true
            Grade.isEnabled = true
            //Name.isEnabled = true
            spot.isEnabled = true
            Born.isEnabled = true
            BattleGround.isEnabled = true
            LeagueOfLegend.isEnabled = true
            OverWatch.isEnabled = true
            Lineage.isEnabled = true
            //gender.isEnabled = true
            Comment.isEnabled = true
            Etc.isEnabled = true
            
            tap = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
            ProfileImage.isUserInteractionEnabled = true
            ProfileImage.addGestureRecognizer(tap)
            
        } else {
            isEditingProfile = true
            switchButton.setTitle("수정하기", for: .normal)
            
            Nickname.isEnabled = false
            Grade.isEnabled = false
            //Name.isEnabled = false
            spot.isEnabled = false
            Born.isEnabled = false
            //gender.isEnabled = false
            Comment.isEnabled = false
            
            BattleGround.isEnabled = false
            LeagueOfLegend.isEnabled = false
            Lineage.isEnabled = false
            OverWatch.isEnabled = false
            Etc.isEnabled = false
            
            ProfileImage.isUserInteractionEnabled = false
            ProfileImage.removeGestureRecognizer(tap)
            
            self.saveEditProfile()
            self.uploadImage()
            //self.saveEditCoreData()
            self.reloadInputViews()
            
        }
        
    }
    
    @IBAction func battlegroundTapped(_ sender: Any) {
        
        if BattleGround.isSelected {
            BattleGround.isSelected = false
            if hoGame1 == "배틀그라운드" {
                hoGame1 = ""
            } else if hoGame2 == "배틀그라운드" {
                hoGame2 = ""
            } else if hoGame3 == "배틀그라운드" {
                hoGame3 = ""
            }
            maximum += 1
        } else if !BattleGround.isSelected {
            BattleGround.isSelected = true
            maximum -= 1
            if maximum < 0 {
                let alert = UIAlertController(title: "최대 개수 초과", message: "3개 이하로 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: { action in
                    self.BattleGround.isSelected = false
                    self.maximum += 1
                })
                
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                if hoGame1 == "" {
                    hoGame1 = "배틀그라운드"
                } else if hoGame2 == "" {
                    hoGame2 = "배틀그라운드"
                } else if hoGame3 == "" {
                    hoGame3 = "배틀그라운드"
                }
            }
        }
    }
    
    @IBAction func overwatchTapped(_ sender: Any) {
        if OverWatch.isSelected {
            OverWatch.isSelected = false
            if hoGame1 == "오버워치" {
                hoGame1 = ""
            } else if hoGame2 == "오버워치" {
                hoGame2 = ""
            } else if hoGame3 == "오버워치" {
                hoGame3 = ""
            }
            maximum += 1
        } else if !OverWatch.isSelected {
            OverWatch.isSelected = true
            maximum -= 1
            if maximum < 0 {
                let alert = UIAlertController(title: "최대 개수 초과", message: "3개 이하로 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: { action in
                    self.OverWatch.isSelected = false
                    self.maximum += 1
                })
                
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                if hoGame1 == "" {
                    hoGame1 = "오버워치"
                    
                } else if hoGame2 == "" {
                    hoGame2 = "오버워치"
                    
                } else if hoGame3 == "" {
                    hoGame3 = "오버워치"
                    
                }
            }
        }
    }
    
    @IBAction func lolTapped(_ sender: Any) {
        if LeagueOfLegend.isSelected {
            LeagueOfLegend.isSelected = false
            if hoGame1 == "리그오브레전드" {
                hoGame1 = ""
            } else if hoGame2 == "리그오브레전드" {
                hoGame2 = ""
            } else if hoGame3 == "리그오브레전드" {
                hoGame3 = ""
            }
            maximum += 1
        } else if !LeagueOfLegend.isSelected {
            LeagueOfLegend.isSelected = true
            maximum -= 1
            if maximum < 0 {
                let alert = UIAlertController(title: "최대 개수 초과", message: "3개 이하로 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: { action in
                    self.LeagueOfLegend.isSelected = false
                    self.maximum += 1
                })
                
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                if hoGame1 == "" {
                    hoGame1 = "리그오브레전드"
                } else if hoGame2 == "" {
                    hoGame2 = "리그오브레전드"
                } else if hoGame3 == "" {
                    hoGame3 = "리그오브레전드"
                }
            }
        }
    }
    
    @IBAction func lineageTapped(_ sender: Any) {
        if Lineage.isSelected {
            Lineage.isSelected = false
            if hoGame1 == "리니지" {
                hoGame1 = ""
            } else if hoGame2 == "리니지" {
                hoGame2 = ""
            } else if hoGame3 == "리니지" {
                hoGame3 = ""
            }
            maximum += 1
        } else if !Lineage.isSelected {
            Lineage.isSelected = true
            maximum -= 1
            if maximum < 0 {
                let alert = UIAlertController(title: "최대 개수 초과", message: "3개 이하로 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: { action in
                    self.Lineage.isSelected = false
                    self.maximum += 1
                })
                
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                if hoGame1 == "" {
                    hoGame1 = "리니지"
                } else if hoGame2 == "" {
                    hoGame2 = "리니지"
                } else if hoGame3 == "" {
                    hoGame3 = "리니지"
                }
            }
        }
    }
    
    @IBAction func etcTapped(_ sender: Any) {
        if Etc.isSelected {
            Etc.isSelected = false
            if hoGame1 == "기타" {
                hoGame1 = ""
            } else if hoGame2 == "기타" {
                hoGame2 = ""
            } else if hoGame3 == "기타" {
                hoGame3 = ""
            }
            maximum += 1
        } else if !Etc.isSelected {
            Etc.isSelected = true
            maximum -= 1
            if maximum < 0 {
                let alert = UIAlertController(title: "최대 개수 초과", message: "3개 이하로 선택해주세요", preferredStyle: .alert)
                let done = UIAlertAction(title: "확인", style: .cancel, handler: { action in
                    self.Etc.isSelected = false
                    self.maximum += 1
                })
                
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                if hoGame1 == "" {
                    hoGame1 = "기타"
                } else if hoGame2 == "" {
                    hoGame2 = "기타"
                } else if hoGame3 == "" {
                    hoGame3 = "기타"
                }
            }
        }
    }
    
    func saveEditCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let dbRequest = NSFetchRequest<NSFetchRequestResult>()
        
        dbRequest.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(dbRequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                match.setValue(self.Nickname.text!, forKey: "nickname")
                match.setValue(self.genderValue, forKey: "gender")
                match.setValue(self.Grade.text!, forKey: "grade")
                match.setValue(self.Comment.text!, forKey: "comment")
                match.setValue(self.Born.text!, forKey: "born")
                match.setValue(imageId, forKey: "imageId")
                match.setValue(self.spot.text!, forKey: "spot")
                match.setValue(self.BattleGround.isSelected, forKey: "battleground")
                match.setValue(self.OverWatch.isSelected, forKey: "overwatch")
                match.setValue(self.LeagueOfLegend.isSelected, forKey: "lol")
                match.setValue(self.Lineage.isSelected, forKey: "lineage")
                match.setValue(self.Etc.isSelected, forKey: "etc")
                match.setValue(self.hoGame1, forKey: "hoGame1")
                match.setValue(self.hoGame2, forKey: "hoGame2")
                match.setValue(self.hoGame3, forKey: "hoGame3")
                do {
                    try DBLib.coreDataLIB.managedObjectContext.save()
                    print("success")
                } catch {
                    print("save error")
                }
                
            } else {
                print("nothing Founded")
            }
        } catch {
            print("Error : \(error.localizedDescription)")
        }
    }
    
    func saveEditProfile() {
        print("saveEditProfile")
        imageId = self.gameId.text! + ".jpg"
        
        let editUrl = URL(string: URLLib.urlObject.serverUrl + "/user/update")
        var request = URLRequest(url: editUrl!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.gameId.text!)", "nick" : "\(self.Nickname.text!)", "spot" : "\(self.spot.text!)", "imageid" : "\(imageId)", "birth" : "\(self.Born.text!)", "rate" : "\(self.Grade.text!)", "info" : "\(self.Comment.text!)", "hoGame1" : "\(self.hoGame1)", "hoGame2" : "\(self.hoGame2)", "hoGame3" : "\(self.hoGame3)", "hoSpot" : "\(self.spot.text!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out." {
                    print("서버 타임아웃")
                }
            } else {
                DispatchQueue.main.async {
                    do {
//                        let httpResponse = response as! HTTPURLResponse
//
//                        if httpResponse.statusCode == 200 {
//                            self.saveEditCoreData()
//                        }
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                        let checkJSON = parseJSON["result"] as? String
                        
                        if checkJSON == "1" {
                            self.saveEditCoreData()
                        } else {
                            print("서버 에러")
                        }
                        
                    } catch {
                        print("parse error")
                    }
                }
            }
            
        }) .resume()
    }
    
    func uploadImage() {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
    
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((ProfileImage.image?.resizeWithWidth(width: 100))!, 0.5)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let mimetype = "image/*"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"; filename=\"\(imageId)\"\r\n".data(using: String.Encoding.utf8)!)
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
        
        ProfileImage.image = selectedImage
        ProfileImage.contentMode = .scaleToFill
    }
    
    @objc func keyboardUp(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            self.view.frame.origin.y -= 30
        }
    }
    
    @objc func keyboardDown(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == Nickname {
            
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 7
        } else if textField == Comment {
            
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= limitLength
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Grade.resignFirstResponder()
        Nickname.resignFirstResponder()
        spot.resignFirstResponder()
        Born.resignFirstResponder()
        Comment.resignFirstResponder()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//
//        if segue.identifier == "settingSegue" {
//            let destination = (segue.destination as! UITabBarController).viewControllers![2] as! clanDataUpdateViewController
//
//        }
//    }
 

}
