//
//  TabBarViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 12..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TabBarViewController: UITabBarController {
    
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        self.selectedIndex = 0
        
        self.title = "게임친구"
        //self.navigationItem.rightBarButtonItem = searchButton
        
//        self.loadGAD()
        
        // Do any additional setup after loading the view.
    }
    
    func loadGAD() {
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-3261416719691453/3046959346"
        bannerView.rootViewController = self
        let height = self.view.frame.size.height / 11
        bannerView.frame = CGRect(x: 0, y: (view.bounds.height - bannerView.frame.size.height) - 50, width: self.view.bounds.size.width, height: 50)
        bannerView.load(GADRequest())
        
        self.view.addSubview(bannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
