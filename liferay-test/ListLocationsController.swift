//
//  ViewController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit
import SwiftSoup

class ListLocationsController: BaseController, UIWebViewDelegate {

    
    @IBOutlet var webview: UIWebView?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.webview?.scrollView.bounces = false
        self.webview?.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("liferay.locations", comment: "Liferay locations")
        //let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "asset/www")
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let url = documentDirectory.appendingPathComponent("dist/www/index.html")
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        self.webview?.loadRequest(request as URLRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            
            DispatchQueue.main.async() {
                [unowned self] in
                
                self.performSegue(withIdentifier: "goToDetail", sender: request.url)
            }
            
        }
        return true;
    }

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
      
        let urlSelected = sender as? URL
        
        let urlString = urlSelected?.absoluteString
        //let path = urlString?.replacingOccurrences(of: "stejeros://", with: "")
        let name = urlSelected?.valueOf(queryParamaterName: "name");
        
        
        let detailViewcontroller = (segue.destination as! DetailLocationController)
        detailViewcontroller.navigationItem.title = name
        detailViewcontroller.detailSelected = name
    }
    
    
    
}

