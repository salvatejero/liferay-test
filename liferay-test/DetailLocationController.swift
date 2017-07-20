//
//  DetailLocationController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 20/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import Foundation
import UIKit


class DetailLocationController: BaseController {

    @IBOutlet var webview: UIWebView?
    
    public var detailSelected : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backItem?.title = NSLocalizedString("back", comment: "Back")
        self.webview?.scrollView.bounces = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "asset/www")
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let url = documentDirectory.appendingPathComponent("dist/www/"+self.detailSelected!+".html")
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        
        
        
        self.webview?.loadRequest(request as URLRequest)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
