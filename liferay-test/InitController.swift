//
//  InitController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit

import SwiftSoup

class InitController: BaseController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "base", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            
            var language : String = Locale.preferredLanguages[0]
            if (language.contains("-")){
                language = language.components(separatedBy: "-")[0]
            }
            let baseUrl = (dict.object(forKey: "baseUrl") as! String).replacingOccurrences(of: "language", with: language)
            
            let url: URL = NSURL(string: baseUrl)! as URL
           
            do {
                let baseHTMLString = try String(contentsOf: url, encoding: .ascii)
                do{
                    let doc: Document = try SwiftSoup.parse(baseHTMLString)
                    
                    let liMenubars : Elements =  try! doc.select("#sectionNavigation > ul[role=\"menubar\"] li a")
                    
                    
                    liMenubars.forEach { liMenu in
                        let text : String = try! liMenu.text()
                        let href : String = try! liMenu.attr("href")
                        let locationZones = try! doc.select(href)
                        
                        let offices = try! locationZones.select(".journal-content-article")
                        var finalCard = String()
                        for (index, office) in offices.enumerated() {
                            var card = NSLocalizedString("card", comment: "card")
                            card = card.replacingOccurrences(of: "<!-- IMG -->", with: try! office.select("svg").outerHtml())
                            card = card.replacingOccurrences(of: "<!-- NAME -->", with: try! office.select("h2").text())
                            card = card.replacingOccurrences(of: "<!-- DIRECTION -->", with: try! office.select("address").outerHtml())
                            finalCard = finalCard+card
                            print("Item \(index): \(office)")
                        }
                        
                        var elementDict = [String : String]()
                        elementDict["id"] = "detail.html?name="+text+href
                        elementDict["name"] = text
                        
                        
                        
                        replaceLocationsList(liMenubars: elementDict)
                        
                        createDetailFile(name: text, content: finalCard)
                        print(try! liMenu.text())
                    }
                    
                    
                    DispatchQueue.main.async() {
                        [unowned self] in
                        self.performSegue(withIdentifier: "goToMain", sender: self)
                    }

                    
                }catch Exception.Error(let type, let message){
                    print("Error type: \(type.hashValue)" + "  Message :"+message)
                }catch{
                    print("Error")
                }
                
                
            } catch let error {
                print("Error: \(error)")
            }
        }
        
        
    }
    
    func replaceLocationsList(liMenubars : [String : String]){
        
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = documentDirectory.appendingPathComponent("dist/www/index.html")
        
        do {
            
            var fileContent = try String(contentsOf: fileURL)
            
            var liTextFinal = String()
            
            var liText = NSLocalizedString("list.li", comment: "nothing")
            liText = liText.replacingOccurrences(of: "@link", with: "stejeros://"+liMenubars["id"]!)
            liText = liText.replacingOccurrences(of: "@name", with: liMenubars["name"]!)
            liTextFinal = liTextFinal+liText+"<!-- REPLACE_LIST_LOCATIONS -->"
            
            
            fileContent = fileContent.replacingOccurrences(of: "<!-- REPLACE_LIST_LOCATIONS -->", with: liTextFinal)
            
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            
        } catch {
            print("error reading to url:", fileURL, error)
        }
        
        
        
    }
    
    func createDetailFile(name: String, content: String){
    
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirectory.appendingPathComponent("dist/www/"+name+".html")
        let fileAboutURL = documentDirectory.appendingPathComponent("dist/www/about.html")
        let fileAboutContent = try! String(contentsOf: fileAboutURL)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let fileContent = fileAboutContent.replacingOccurrences(of: "<!-- CONTENT -->", with: content)
            if let fileHandle = try? FileHandle(forUpdating: fileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(fileContent.data(using: .isoLatin1)!)
                fileHandle.closeFile()
                
            }
        } else {
            
            let fileContent = fileAboutContent.replacingOccurrences(of: "<!-- CONTENT -->", with: content)
            try! fileContent.write(to: fileURL, atomically: true, encoding: .isoLatin1)
        }
    
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
