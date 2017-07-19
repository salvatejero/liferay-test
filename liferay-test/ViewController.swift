//
//  ViewController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var webview: UIWebView?
    
    @IBOutlet var navigationBar: UINavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar?.topItem?.title = "Liferay locations"
        navigationBar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.isTranslucent = true
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "asset/www")
        
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url!)
        self.webview?.scrollView.bounces = false
        self.webview?.loadRequest(request as URLRequest)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

}

