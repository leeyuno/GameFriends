//
//  photoUploadViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 10. 11..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class photoUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoImage2: UIImageView!
    @IBOutlet weak var photoImage3: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    @IBOutlet weak var contents: UITextView!
    
    var userid = ""
    var clanid = ""
    var imageid = ""
    var imageid2 = ""
    var imageid3 = ""
    
    var numberOfImage = 0
    var isSelcted = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contents.text = "내용을 입력해주세요."
        contents.textColor = UIColor.lightGray
        contents.delegate = self
        
        photoImage.layer.masksToBounds = true
        photoImage.layer.cornerRadius = 5
        photoImage.layer.borderColor = UIColor.lightGray.cgColor
        photoImage.layer.borderWidth = 0.3
        
        photoImage2.layer.masksToBounds = true
        photoImage2.layer.cornerRadius = 5
        photoImage2.layer.borderColor = UIColor.lightGray.cgColor
        photoImage2.layer.borderWidth = 0.3
        
        photoImage3.layer.masksToBounds = true
        photoImage3.layer.cornerRadius = 5
        photoImage3.layer.borderColor = UIColor.lightGray.cgColor
        photoImage3.layer.borderWidth = 0.3
        
        uploadButton.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = 5
        uploadButton.layer.borderColor = UIColor.lightGray.cgColor
        uploadButton.layer.borderWidth = 0.3
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionSheet))
        photoImage.isUserInteractionEnabled = true
        photoImage.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(actionSheet2))
        photoImage2.isUserInteractionEnabled = true
        photoImage2.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(actionSheet3))
        photoImage3.isUserInteractionEnabled = true
        photoImage3.addGestureRecognizer(tap3)
        
        let keyboardHide = UISwipeGestureRecognizer(target: self, action: #selector(keyboardHideAction))
        keyboardHide.direction = .down
        contents.addGestureRecognizer(keyboardHide)
        contents.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImageButton(_ sender: Any) {
        actionSheet()
    }
    
    @objc func actionSheet() {
        isSelcted = 1
        let alert = UIAlertController(title: "사진을 업로드해주세요.", message: "사진을 업로드해주세요.", preferredStyle: .actionSheet)
        let albumAction = UIAlertAction(title: "앨범", style: .default, handler: { action -> Void in
            self.useAlbum()
        })
        let photoAction = UIAlertAction(title: "카메라", style: .default, handler: { action -> Void in
            self.usePhoto()
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "지우기", style: .default, handler: { action -> Void in
            self.deletePhoto()
        })
        
        alert.addAction(photoAction)
        alert.addAction(albumAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func actionSheet2() {
        isSelcted = 2
        let alert = UIAlertController(title: "사진을 업로드해주세요.", message: "사진을 업로드해주세요.", preferredStyle: .actionSheet)
        let albumAction = UIAlertAction(title: "앨범", style: .default, handler: { action -> Void in
            self.useAlbum()
        })
        let photoAction = UIAlertAction(title: "카메라", style: .default, handler: { action -> Void in
            self.usePhoto()
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "지우기", style: .default, handler: { action -> Void in
            self.deletePhoto()
        })
        
        alert.addAction(photoAction)
        alert.addAction(albumAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func actionSheet3() {
        isSelcted = 3
        let alert = UIAlertController(title: "사진을 업로드해주세요.", message: "사진을 업로드해주세요.", preferredStyle: .actionSheet)
        let albumAction = UIAlertAction(title: "앨범", style: .default, handler: { action -> Void in
            self.useAlbum()
        })
        let photoAction = UIAlertAction(title: "카메라", style: .default, handler: { action -> Void in
            self.usePhoto()
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "지우기", style: .default, handler: { action -> Void in
            self.deletePhoto()
        })
        
        alert.addAction(photoAction)
        alert.addAction(albumAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }

    func useAlbum() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.show(picker, sender: nil)
//        self.present(picker, animated: true, completion: nil)
    }
    
    func usePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        self.show(picker, sender: nil)
    }
    
    func deletePhoto() {
        if isSelcted == 1 {
            photoImage.image = UIImage(named: "add-image")
        } else if isSelcted == 2 {
            photoImage2.image = UIImage(named: "add-image")
        } else if isSelcted == 3 {
            photoImage3.image = UIImage(named: "add-image")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if isSelcted == 1 {
            photoImage.image = selectedImage
        } else if isSelcted == 2 {
            photoImage2.image = selectedImage
        } else if isSelcted == 3 {
            photoImage3.image = selectedImage
        }
    }
    
    func uploadImage(_ imageId: String, _ imageId2: String, _ imageId3: String) {

        let url = URL(string: URLLib.urlObject.serverUrl + "/clan/gallery/upload")
        var request = URLRequest(url: url!)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let json = ["userid" : "\(self.userid)", "clanid" : "\(self.clanid)", "imageid" : "\(imageId)", "imageid2" : "\(imageId2)", "imageid3" : "\(imageId3)", "contents" : "\(self.contents.text!)"]
        print(json)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let httpResponse = response as! HTTPURLResponse
                
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.uploadSuccess()
                    }
                }
            }
        }) .resume()
    }
    
    func imageUpload(_ imageId: String) {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/gallery_uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((photoImage.image?.resizeWithWidth(width: 500))!, 0.5)
        
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
    
    func imageUpload2(_ imageId: String) {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/gallery_uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((photoImage2.image?.resizeWithWidth(width: 500))!, 0.5)
        
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
    
    func imageUpload3(_ imageId: String) {
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/gallery_uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((photoImage3.image?.resizeWithWidth(width: 500))!, 0.5)
        
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
    
    func uploadSuccess() {
        let alert = UIAlertController(title: "업로드에 성공했습니다.", message: "업로드에 성공했습니다.", preferredStyle: .alert)
        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            //self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @objc func keyboardHideAction() {
        contents.resignFirstResponder()
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        
        if photoImage.image == UIImage(named: "add-image") && photoImage2.image == UIImage(named: "add-image") && photoImage3.image == UIImage(named: "add-image") {
            let alert = UIAlertController(title: "사진을 에러.", message: "사진을 확인해주세요.", preferredStyle: .alert)
            let done = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            
            alert.addAction(done)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let value = arc4random()
            
            if photoImage.image != UIImage(named: "add-image") {
                numberOfImage += 1
                imageid = userid + "_" + "\(value)" + "_" + "1.jpg"
                imageUpload(imageid)
            } else {
                imageid = ""
            }
            if photoImage2.image != UIImage(named: "add-image") {
                numberOfImage += 1
                imageid2 = userid + "_" + "\(value)" + "_" + "2.jpg"
                imageUpload2(imageid2)
            } else {
                imageid2 = ""
            }
            if photoImage3.image != UIImage(named: "add-image") {
                numberOfImage += 1
                imageid3 = userid + "_" + "\(value)" + "_" + "3.jpg"
                imageUpload3(imageid3)
            } else {
                imageid3 = ""
            }
            
            self.uploadImage(imageid, imageid2, imageid3)
//            self.uploadImage()
//            self.imageUpload()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contents.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.textColor == UIColor.lightGray {
            
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "내용을 입력해주세요"
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
