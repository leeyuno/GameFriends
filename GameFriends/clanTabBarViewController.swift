//
//  clanTabBarViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 16..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import CoreData

class clanTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    var bannerView: GADBannerView!

    var clanId = ""
    var userId = ""
    var clanImageId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
//        self.loadGAD()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: DBLib.coreDataLIB.managedObjectContext)
        var request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try DBLib.coreDataLIB.managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                userId = match.value(forKey: "id") as! String
            }
            
        } catch {
            print("asdfadsfadsf")
        }
        
        let backButton = UIBarButtonItem(title: "메인", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.rightBarButtonItem = backButton
        
        let homeButton = UIBarButtonItem(title: "클랜홈", style: .plain, target: self, action: #selector(homeAction))
        self.navigationItem.leftBarButtonItem = homeButton
        // Do any additional setup after loading the view.
        
        self.selectedIndex = 0
        self.navigationItem.hidesBackButton = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationTitleImage()
        self.tabBarController?.tabBar.isHidden = false
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let tabBarIndex = tabBarController.selectedIndex
//        if tabBarIndex == 3 {
//            self.bannerView.isHidden = true
//        }
//    }

    func navigationTitleImage() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0.2
        
        let imageUrl = URL(string: URLLib.urlObject.serverUrl + "/clan_download/\(self.clanImageId)")
        
        let data = NSData(contentsOf: imageUrl!)
        var myImage = UIImage(data: data! as Data)
        
        myImage = myImage?.resizeWithWidth(width: 40)
        
        let compressData = UIImageJPEGRepresentation(myImage!, 1)
//        imageView.downloadedFrom(url: imageUrl!)
        imageView.image = UIImage(data: compressData!)
        imageView.contentMode = .scaleToFill
        
        navigationItem.titleView = imageView
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func homeAction() {
        self.tabBarController?.tabBar.isHidden = false
        self.selectedIndex = 0
//        self.bannerView.isHidden = false
    }
    
    func loadGAD() {
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-3261416719691453/3046959346"
        bannerView.rootViewController = self
        bannerView.frame = CGRect(x: 0, y: (view.bounds.height - bannerView.frame.size.height) - 50, width: self.view.bounds.size.width, height: 50)
        bannerView.load(GADRequest())
        
        self.view.addSubview(bannerView)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let vc = self.tabBarController?.viewControllers?[0] as! ClanHomeViewController
        vc.clanId = self.clanId
    }
 

}
