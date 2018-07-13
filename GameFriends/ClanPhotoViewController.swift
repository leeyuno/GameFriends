//
//  ClanPhotoViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class ClanPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var userid = ""
    var clanid = ""
    var photoid = ""
    var author = ""
    
    var photoList = [[String]]()
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoUpload.layer.masksToBounds = true
        photoUpload.layer.cornerRadius = self.photoUpload.frame.size.height / 2

        // Do any additional setup after loading the view.
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                userid = match.value(forKey: "id") as! String
            }
        } catch {
            print("nothing founded")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadPhotoData()
    }
    
    func configureCollectionView() {
        photoCollectionView.bounces = false
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.reloadData()
        photoCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func loadPhotoData() {
        self.photoList.removeAll()
        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/list")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["userid" : "\(self.userid)", "clanid" : "\(self.clanid)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        let arrJSON = parseJSON["result"] as? NSArray
                        
                        if arrJSON == nil {
                            let alert = UIAlertController(title: "사진첩이 비어있습니다.", message: "사진을 등록해주세요", preferredStyle: .alert)
                            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                            
                            alert.addAction(done)
                            
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            for i in 0 ... (arrJSON?.count)! - 1 {
                                let aObject = arrJSON?[i] as! [String : AnyObject]
                                
                                let bObject = aObject["data"] as! NSArray
                                
                                for j in 0 ... bObject.count - 1 {
                                    let cObject = bObject[j] as! [String: AnyObject]
                                    var mainImage = ""
                                    
                                    if cObject["imageId"] as! String == "" {
                                        if cObject["imageId2"] as! String == "" {
                                            mainImage = cObject["imageId3"] as! String
                                        } else {
                                            mainImage = cObject["imageId2"] as! String
                                        }
                                    } else {
                                        mainImage = cObject["imageId"] as! String
                                    }
                                    self.photoList.append([cObject["_id"] as! String, mainImage, cObject["created_at"] as! String, cObject["writerNick"] as! String, cObject["writer"] as! String])
                                }
                            }
                        }

                    } catch {
                        print("catch")
                    }
                    
                    self.configureCollectionView()
                }
            }
            
        }) .resume()
        
    }
    
    @IBOutlet weak var photoUpload: UIButton!
    @IBAction func photoUpload(_ sender: Any) {
        self.photoUploadSegue()
    }
    
    
    func photoUploadSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "photoUploadSegue", sender: self)
        }
    }
    
    func photoDetailSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "photoDetailSegue", sender: self)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellectionView cellForItemAt")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.4
//        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 5
        let url = URL(string: URLLib.urlObject.serverUrl + "/gallery_download/\(photoList[indexPath.row][1])")
        
//        cell.photoImage.downloadedFrom(url: url!)
        cell.photoImage.kf.setImage(with: url!)
        cell.photoImage.contentMode = .scaleAspectFit
        
        let dateTmp = photoList[indexPath.row][2]
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let dateFromString = dateFormatter.date(from: dateTmp)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = tempLocale
        let stringFromDate = dateFormatter.string(from: dateFromString!)
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/download/\(photoList[indexPath.row][4]).jpg")
//        cell.userImage.downloadedFrom(url: imageUrl!)
        cell.userImage.kf.setImage(with: imageUrl!)
        cell.userImage.contentMode = .scaleToFill
        cell.userImage.layer.masksToBounds = true
        cell.userImage.layer.borderWidth = 0.4
        cell.userImage.layer.borderColor = UIColor.lightGray.cgColor
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.height / 2
        
        cell.userNickname.text = photoList[indexPath.row][3]
        cell.create_at.text = stringFromDate
        
        cell.setCornerRadious(10)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellsAcross: CGFloat = 2
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        
        return CGSize(width: dim, height: dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photoid = photoList[indexPath.row][0]
        self.photoDetailSegue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoUploadSegue" {
            let destination = segue.destination as! photoUploadViewController
            destination.userid = self.userid
            destination.clanid = self.clanid
        } else if segue.identifier == "photoDetailSegue" {
            let destination = segue.destination as! photoDetailViewController
            destination.userid = self.userid
            destination.clanid = self.clanid
            destination.photoid = self.photoid
            destination.author = self.author
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
