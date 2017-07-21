//
//  ViewController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftSoup
import ContactsUI

class ListLocationsController: BaseController, UIWebViewDelegate, LocationServiceDelegate {
    
    public var locations : [String] = [String]()
    
    @IBOutlet var webview: UIWebView?
    
    var semaforo : Bool = false
    
    public var locateCard: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("liferay.locations", comment: "Liferay locations")
        
        LocationService.sharedInstance.delegate = self
        self.webview?.scrollView.bounces = false
        self.webview?.delegate = self
        
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let url = documentDirectory.appendingPathComponent("dist/www/index.html")
        
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url )
        
        self.webview?.loadRequest(request as URLRequest)
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            
            if request.url?.scheme == "tel"{
                return false
            }else if(request.url?.scheme == "contact"){
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
                
            }else{
                DispatchQueue.main.async() {
                    [unowned self] in
                
                    self.performSegue(withIdentifier: "goToDetail", sender: request.url)
                }
            }
            
        }
        return true;
    }

    func tracingLocationDidFailWithError(_ error: NSError) {
        
    }
        
    func tracingLocation(_ currentLocation: CLLocation) {
        // Send to javascript the current Location
        if (!semaforo && !LocationService.sharedInstance.country.isEmpty){
            semaforo = true
            if let i = self.locations.index(where: { $0.contains(LocationService.sharedInstance.country) || $0.contains(LocationService.sharedInstance.countryEn) }) {
                var trimmed = self.locations[i].replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
                trimmed = String(trimmed.characters.filter { !"\n\t\r".characters.contains($0) })
                trimmed = trimmed.replacingOccurrences(of: "\"", with: "'")
                let function = "sendCountry(\""+trimmed+"\")";
                self.webview?.stringByEvaluatingJavaScript(from: function)
                return
            }else{
                let function = "sendCountry(\"\")";
                self.webview?.stringByEvaluatingJavaScript(from: function)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        let urlSelected = sender as? URL
        
        let name = urlSelected?.valueOf(queryParamaterName: "name");
        
        let detailViewcontroller = (segue.destination as! DetailLocationController)
        
        detailViewcontroller.navigationItem.title = name
        detailViewcontroller.detailSelected = name
    }
      
}

