//
//  DetailLocationController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 20/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

class DetailLocationController: BaseController, UIWebViewDelegate {

    @IBOutlet var webview: UIWebView?
    
    public var detailSelected : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview?.delegate = self
        self.webview?.scrollView.bounces = false
        
        
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let url = documentDirectory.appendingPathComponent("dist/www/"+self.detailSelected!+".html")
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        self.webview?.loadRequest(request as URLRequest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
                
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            
            if(request.url?.scheme == "contact"){
                let name = request.url?.valueOf(queryParamaterName: "name")!
                let tel = request.url?.valueOf(queryParamaterName: "tel")!
                let company = request.url?.valueOf(queryParamaterName: "bu")!
                
                let newContact = CNMutableContact()
                newContact.givenName = name!
                newContact.middleName = company!
                newContact.organizationName = company!
                let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: tel!.replacingOccurrences(of: "Tel:", with: "")))
                newContact.phoneNumbers = [homePhone]
                
                self.contactLink(contact: newContact)

            }
            
        }
        return true;
    }
    
}
