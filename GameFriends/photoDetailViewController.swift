//
//  photoDetailViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class photoDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, replyDelegate, UITextViewDelegate {

    var userid = ""
    var clanid = ""
    var photoid = ""
    var author = ""
    var userName = ""
//    var replyId = ""
    
    @IBOutlet weak var contentsBottom: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeConstraint: NSLayoutConstraint!
    @IBOutlet weak var image1Bottom: NSLayoutConstraint!
    
    let limitLength = 25
    
    var photoObject = [String]()
    var commentsObject = [[String]]()
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var photoSubView: UIView!
    
    @IBOutlet weak var replyView: UIView!
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoImage2: UIImageView!
    @IBOutlet weak var photoImage3: UIImageView!
    @IBOutlet weak var contents: UITextView!
    
    @IBOutlet weak var replyTableView: UITableView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeText: UILabel!
    var likeCount = 0
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userNick: UILabel!
    @IBOutlet weak var createTime: UILabel!
    
    var imageDownUrl = ""
    
    @IBOutlet weak var detailScroll: UIScrollView!
    @IBOutlet var photoDetailView: UIView!
    @IBOutlet weak var detailImage: UIImageView!
    
    var clickImage: UIImageView!
    
    var replyObject = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.isHidden = true

        if self.author == self.userid {
            deleteButton.isHidden = false
        }

        automaticallyAdjustsScrollViewInsets = false
        //self.loadPhoto()
        // Do any additional setup after loading the view.
        
        replyTableView.layer.masksToBounds = true
        replyTableView.layer.borderColor = UIColor.black.cgColor
        replyTableView.layer.borderWidth = 0.4
        
        contents.layer.masksToBounds = true
        contents.layer.borderColor = UIColor.black.cgColor
        contents.layer.borderWidth = 0.4
        contents.layer.cornerRadius = 10
        
        userPhoto.layer.masksToBounds = true
        userPhoto.layer.borderColor = UIColor.black.cgColor
        userPhoto.layer.borderWidth = 0.4
        userPhoto.layer.cornerRadius = 10
        
        photoImage.layer.masksToBounds = true
        photoImage.layer.borderColor = UIColor.black.cgColor
        photoImage.layer.borderWidth = 0.4
        photoImage.layer.cornerRadius = 10
        
        photoImage2.layer.masksToBounds = true
        photoImage2.layer.borderColor = UIColor.black.cgColor
        photoImage2.layer.borderWidth = 0.4
        photoImage2.layer.cornerRadius = 10
        
        photoImage3.layer.masksToBounds = true
        photoImage3.layer.borderColor = UIColor.black.cgColor
        photoImage3.layer.borderWidth = 0.4
        photoImage3.layer.cornerRadius = 10

        configureScrollView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: .UIKeyboardDidHide, object: nil)
        
        likeButton.layer.masksToBounds = true
        likeButton.layer.cornerRadius = 5
        likeButton.layer.borderWidth = 0.5
        likeButton.layer.borderColor = UIColor.lightGray.cgColor
        
        replyButton.layer.masksToBounds = true
        replyButton.layer.cornerRadius = 5
        replyButton.layer.borderWidth = 0.5
        replyButton.layer.borderColor = UIColor.lightGray.cgColor
        
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.lightGray.cgColor
        
        let keyboardHide = UISwipeGestureRecognizer(target: self, action: #selector(keyboardHideAction))
        keyboardHide.direction = .down
        
        self.view.addGestureRecognizer(keyboardHide)
        replyView.addGestureRecognizer(keyboardHide)
        replyTableView.addGestureRecognizer(keyboardHide)
        
        replyTextField.delegate = self
        
        contents.isEditable = false
        contents.delegate = self
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let entityRequest = NSFetchRequest<NSFetchRequestResult>()
        
        entityRequest.entity = entityDescription
        
        do {
            let object = try DBLib.coreDataLIB.managedObjectContext.fetch(entityRequest)
            
            if object.count > 0 {
                let match = object[0] as! Profile
                self.userName = match.value(forKey: "nickname") as! String
            }
            
        } catch {
            print("asdfasdfasdf")
        }
        
        loadPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadReplyData()
        
    }
    
    override func viewWillLayoutSubviews() {
        detailScroll.minimumZoomScale = 1.0
        detailScroll.maximumZoomScale = 5.0
        detailScroll.zoomScale = 1.0
    }
    
    @objc func detailClick() {
        self.imageDownUrl = URLLib.urlObject.serverUrl + "/gallery_download/\(self.photoObject[0])"
        self.clickSegue()
    }
    
    @objc func detailClick2() {
        self.imageDownUrl = URLLib.urlObject.serverUrl + "/gallery_download/\(self.photoObject[1])"
        self.clickSegue()
    }
    
    @objc func detailClick3() {
        self.imageDownUrl = URLLib.urlObject.serverUrl + "/gallery_download/\(self.photoObject[2])"
        self.clickSegue()
    }
    
    func clickSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "clickSegue", sender: self)
        }
    }
    
    func deleteDetailView() {
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
    }
    @IBAction func hideDetailView(_ sender: Any) {
        deleteDetailView()
    }
    
    @objc func keyboardHideAction() {
        replyTextField.resignFirstResponder()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImage
    }
    
    func configureScrollView() {
        scrollView.delegate = self
        scrollView.bounces = false
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 1.8)
        
        photoSubView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height * 1.8)
        scrollView.addSubview(photoSubView)
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "replyCell", bundle: nil)
        replyTableView.register(nib, forCellReuseIdentifier: "replyCell")
        replyTableView.bounces = false
        replyTableView.separatorStyle = .none
        replyTableView.delegate = self
        replyTableView.dataSource = self
        replyTableView.reloadData()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        self.alertDelete()
    }
    
    func alertReplyDelete(_ replyId: String) {
        let alert = UIAlertController(title: "댓글 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.deleteContents(replyId)
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(done)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertDelete() {
        let alert = UIAlertController(title: "게시글삭제", message: "사진 및 게시글을 지우시겠습니까?", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { Void in
            self.deleteContents("")
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(done)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteContents(_ replyId: String) {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/del")
        
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)", "_id" : "\(self.photoid)", "_id2" : "\(replyId)"]
        
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
                        self.loadPhoto()
                    }
                }
            }
        }) .resume()
    }
    
    func loadPhoto() {
        replyObject.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/view")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)", "_id" : "\(self.photoid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        let arrJSON = parseJSON["result"] as! NSArray
                        
                        let result = arrJSON[0] as! [String: AnyObject]
                        
                        if result["writer"] as! String == self.userid {
                            self.deleteButton.isHidden = false
                        }

                        if arrJSON.count > 0 {
                            let aObject = arrJSON[0] as! [String : AnyObject]
                            
                            let dateTmp = aObject["created_at"] as! String
                            let dateFormatter = DateFormatter()
                            let tempLocale = dateFormatter.locale
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            
                            let dateFromString = dateFormatter.date(from: dateTmp)
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                            dateFormatter.locale = tempLocale
                            let stringFromDate = dateFormatter.string(from: dateFromString!)
                            
                            self.createTime.text = stringFromDate
                            
                            self.contents.text = aObject["contents"] as! String
                            self.contents.centerVertically()
                            
                            if self.contents.text! == "" {
                                print("컨텐츠 없음")
                                self.heightConstraint.constant = 0
                                self.likeConstraint.constant = 10
                                self.contentsBottom.isActive = false
                            } else {
                                self.likeConstraint.isActive = false
                            }
                            
                            self.userNick.text = aObject["writerNick"] as! String
                            
                            let tmpCount = aObject["likeUser"] as! NSArray
                            
                            self.likeCount = tmpCount.count
                            self.likeText.text = "\(self.likeCount)명이 좋아합니다."

                            let userimageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(aObject["writer"] as! String).jpg")
//                            self.userPhoto.downloadedFrom(url: userimageUrl!)
                            self.userPhoto.kf.setImage(with: userimageUrl!)
                            self.userPhoto.contentMode = .scaleToFill
                            
                            var imageName1 = ""
                            var imageName2 = ""
                            var imageName3 = ""
                            
                            if aObject["imageId"] as? String == nil {
                                if aObject["imageId2"] as? String == nil {
                                    if aObject["imageId3"] as? String == nil {
                                        
                                    } else {
                                        imageName1 = aObject["imageId3"] as! String
                                        imageName2 = ""
                                        imageName3 = ""
                                    }
                                } else {
                                    imageName1 = aObject["imageId2"] as! String
                                    if aObject["imageId3"] as! String == "" {
                                        imageName2 = ""
                                        imageName3 = ""
                                    } else {
                                        imageName2 = aObject["imageId3"] as! String
                                        imageName3 = ""
                                    }
                                }
                            } else {
                                imageName1 = aObject["imageId"] as! String
                                if aObject["imageId2"] as? String == nil {
                                    if aObject["imageId3"] as? String == nil {
                                        imageName2 = ""
                                        imageName3 = ""
                                    } else {
                                        imageName2 = aObject["imageId3"] as! String
                                        imageName3 = ""
                                    }
                                } else {
                                    imageName2 = aObject["imageId2"] as! String
                                    if aObject["imageId3"] as? String == nil {
                                        imageName3 = ""
                                    } else {
                                        imageName3 = aObject["imageId3"] as! String
                                    }
                                }
                            }

//                            if aObject["imageId"] as! String == "" {
//                                if aObject["imageId2"] as! String == "" {
//                                    if aObject["imageId3"] as! String == "" {
//
//                                    } else {
//                                        imageName1 = aObject["imageId3"] as! String
//                                        imageName2 = ""
//                                        imageName3 = ""
//                                    }
//                                } else {
//                                    imageName1 = aObject["imageId2"] as! String
//                                    if aObject["imageId3"] as! String == "" {
//                                        imageName2 = ""
//                                        imageName3 = ""
//                                    } else {
//                                        imageName2 = aObject["imageId3"] as! String
//                                        imageName3 = ""
//                                    }
//                                }
//                            } else {
//                                imageName1 = aObject["imageId"] as! String
//                                if aObject["imageId2"] as! String == "" {
//                                    if aObject["imageId3"] as! String == "" {
//                                        imageName2 = ""
//                                        imageName3 = ""
//                                    } else {
//                                        imageName2 = aObject["imageId3"] as! String
//                                        imageName3 = ""
//                                    }
//                                } else {
//                                    imageName2 = aObject["imageId2"] as! String
//                                    if aObject["imageId3"] as! String == "" {
//                                        imageName3 = ""
//                                    } else {
//                                        imageName3 = aObject["imageId3"] as! String
//                                    }
//                                }
//                            }

                            if imageName1 != "" {
                                let photoImageUrl = URL(string: URLLib.urlObject.serverUrl + "/gallery_download/\(imageName1)")
                                
//                                self.photoImage.downloadedFrom(url: photoImageUrl!)
                                self.photoImage.kf.setImage(with: photoImageUrl!)
                                self.photoImage.contentMode = .scaleToFill
                                
                                let tap = UITapGestureRecognizer(target: self, action: #selector(self.detailClick))
                                self.photoImage.isUserInteractionEnabled = true
                                self.photoImage.addGestureRecognizer(tap)
                            } else {

                            }
                            
                            if imageName2 != "" {
                                let photoImageUrl = URL(string: URLLib.urlObject.serverUrl + "/gallery_download/\(imageName2)")
                                
//                                self.photoImage2.downloadedFrom(url: photoImageUrl!)
                                self.photoImage2.kf.setImage(with: photoImageUrl!)
                                self.photoImage2.contentMode = .scaleToFill
                                
                                let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.detailClick2))
                                self.photoImage2.isUserInteractionEnabled = true
                                self.photoImage2.addGestureRecognizer(tap2)
                            } else {
                                self.contents.translatesAutoresizingMaskIntoConstraints = false
                                self.photoImage.translatesAutoresizingMaskIntoConstraints = false
                                self.image1Bottom.constant = 10
                                self.photoImage2.removeFromSuperview()
                            }
                            
                            if imageName3 != "" {
                                self.image1Bottom.isActive = false
                                let photoImageUrl = URL(string: URLLib.urlObject.serverUrl + "/gallery_download/\(imageName3)")
                                
//                                self.photoImage3.downloadedFrom(url: photoImageUrl!)
                                self.photoImage3.kf.setImage(with: photoImageUrl!)
                                self.photoImage3.contentMode = .scaleToFill
                                
                                let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.detailClick3))
                                self.photoImage3.isUserInteractionEnabled = true
                                self.photoImage3.addGestureRecognizer(tap3)
                            } else {
                                if imageName2 != "" {
                                    self.contents.translatesAutoresizingMaskIntoConstraints = false
                                    self.photoImage.translatesAutoresizingMaskIntoConstraints = false
                                    self.photoImage2.translatesAutoresizingMaskIntoConstraints = false
                                    
                                    self.image1Bottom.constant = self.photoImage2.frame.size.height + 20
                                    self.photoImage3.removeFromSuperview()
                                }
                            }
                            
                            self.photoObject.append(imageName1)
                            self.photoObject.append(imageName2)
                            self.photoObject.append(imageName3)
        
                            let likeCheck = aObject["like"] as? Bool
                            
                            if likeCheck != nil {
                                if likeCheck! == true {
                                    self.likeButton.titleLabel?.textColor = UIColor.white
                                    self.likeButton.layer.masksToBounds = true
                                    //self.likeButton.layer.backgroundColor = UIColor.blue.cgColor
                                    self.likeButton.backgroundColor = UIColor(red: 0.44, green: 0.76, blue: 1.00, alpha: 1.0)
                                }
                            }

                            let commentsArray = aObject["comments"] as! NSArray
                            
                            if commentsArray.count > 0 {
                                for i in 0 ... commentsArray.count - 1 {
                                    let bObject = commentsArray[i] as! [String: AnyObject]
                                    
                                    self.replyObject.append([bObject["name"] as! String, bObject["memo"] as! String, bObject["date"] as! String, bObject["nameimage"] as! String, bObject["_id"] as! String])
                                }
                            }
                        }
                    } catch {
                        print("파싱 캐치")
                    }
                    
                    self.configureTableView()
                }
            }
        }) .resume()
    }
    
    func loadReplyData() {
        replyObject.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/view")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["clanid" : "\(self.clanid)", "userid" : "\(self.userid)", "_id" : "\(self.photoid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        let arrJSON = parseJSON["result"] as! NSArray
                        let result = arrJSON[0] as! [String: AnyObject]

                        if arrJSON.count > 0 {
                            let aObject = arrJSON[0] as! [String : AnyObject]
                            
                            let tmpCount = aObject["likeUser"] as! NSArray
                            
                            self.likeCount = tmpCount.count
                            self.likeText.text = "\(self.likeCount)명이 좋아합니다."
                            
                            let likeCheck = aObject["like"] as? Bool
                            
                            if likeCheck != nil {
                                if likeCheck! == true {
//                                    self.likeButton.isSelected = true
                                    
                                    self.likeButton.titleLabel?.textColor = UIColor.white
                                    self.likeButton.layer.masksToBounds = true
                                    //self.likeButton.layer.backgroundColor = UIColor.blue.cgColor
                                    self.likeButton.backgroundColor = UIColor(red: 0.44, green: 0.76, blue: 1.00, alpha: 1.0)
                                } else {
                                    self.likeButton.titleLabel?.textColor = UIColor(red: 0.05, green: 0.39, blue: 1.00, alpha: 1.0)
                                    self.likeButton.layer.masksToBounds = true
                                    //self.likeButton.layer.backgroundColor = UIColor.blue.cgColor
                                    self.likeButton.backgroundColor = UIColor.white
                                }
                            }
                            
                            let commentsArray = aObject["comments"] as! NSArray
                            
                            if commentsArray.count > 0 {
                                for i in 0 ... commentsArray.count - 1 {
                                    let bObject = commentsArray[i] as! [String: AnyObject]
                                    
                                    self.replyObject.append([bObject["name"] as! String, bObject["memo"] as! String, bObject["date"] as! String, bObject["nameimage"] as! String, bObject["_id"] as! String])
                                }
                            }
                        }
                    } catch {
                        print("파싱 캐치")
                    }
                    
                    self.configureTableView()
                }
            }
        }) .resume()
    }
    
    func like() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/like")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "galleryid" : "\(self.photoid)"]
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
    
    func reply() {
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/reply")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "galleryid" : "\(self.photoid)", "memo" : "\(self.replyTextField.text!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == 200 {
                        
                    }
                }
            }
        }) .resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! replyCell

        if replyObject[indexPath.row][0] == self.userName {
            cell.replyDeleteButton.isHidden = false
        } else if self.userid == self.author {
            cell.replyDeleteButton.isHidden = false
        } else {
            cell.replyDeleteButton.isHidden = true
        }
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(self.replyObject[indexPath.row][3])")
        cell.userName.text = replyObject[indexPath.row][0]
        cell.userMemo.text = replyObject[indexPath.row][1]
        
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
        cell.replyId = replyObject[indexPath.row][4]
        cell.viewName = "photo"
        
//        cell.userImage.downloadedFrom(url: imageUrl!)
        cell.userImage.kf.setImage(with: imageUrl!)
        cell.userImage.contentMode = .scaleToFill
        
        cell.replyDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    @IBAction func replyButton(_ sender: Any) {
        replyObject.removeAll()
        
        self.reply()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.loadReplyData()
//            self.configureTableView()
        }
        
        replyTableView.reloadData()
        
        replyTextField.text = ""
        replyTextField.resignFirstResponder()
    }
    
    @IBAction func likeButton(_ sender: Any) {
        
        replyObject.removeAll()
        
        self.like()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.loadReplyData()
        }
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clickSegue" {
            let vc = segue.destination as! clickImageViewController
            vc.imageDownUrl = self.imageDownUrl
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
