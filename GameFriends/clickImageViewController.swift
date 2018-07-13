//
//  clickImageViewController.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 11. 30..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit
import Kingfisher

class clickImageViewController: UIViewController, UIScrollViewDelegate {

    var imageDownUrl = ""
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.delegate = self
        
        let imageUrl = URL(string: imageDownUrl)
        
        let data = NSData(contentsOf: imageUrl!)
        imageView = UIImageView(image: UIImage(data: data! as Data))
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.autoresizesSubviews = true
        scrollView.contentOffset = .zero
        scrollView.backgroundColor = UIColor.lightGray
        scrollView.addSubview(imageView)
    }
    
    override func viewWillLayoutSubviews() {
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
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
