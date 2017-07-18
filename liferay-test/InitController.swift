//
//  InitController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit

import SwiftSoup

class InitController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "base", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let url: URL = NSURL(string: dict.object(forKey: "baseUrl") as! String)! as URL
           
            
            do {
                let baseHTMLString = try String(contentsOf: url, encoding: .ascii)
                
                do{
                    
                    let doc: Document = try SwiftSoup.parse(baseHTMLString)
                    
                    let liMenubars : Elements =  try! doc.select("#sectionNavigation > ul[role=\"menubar\"] li")
                    
                    liMenubars.forEach { liMenu in
                        print(try! liMenu.text())
                    }
                    print(liMenubars)
                }catch Exception.Error(let type, let message)
                {
                    print("")
                }catch{
                    print("")
                }
                
                
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        
        
        
        
        DispatchQueue.main.async() {
            [unowned self] in
            self.performSegue(withIdentifier: "goToMain", sender: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
