//
//  InitController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit
import CoreLocation
import Toast_Swift
import SwiftSoup

class InitController: BaseController {
    
    var locations : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "base", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            prepareApplication(dict: dict)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationcontroller = (segue.destination as! UINavigationController)
        let listViewController = navigationcontroller.viewControllers[0] as! ListLocationsController
        listViewController.locations = self.locations
    }
    
    /**
     Prepare application for a correct work. Copy asset to Docuemtn/dist
     Download and parse the website html
     
     @param dict Dictionary with init paramas.
     
     @return void
     */
    
    func prepareApplication(dict: NSDictionary){
        
        var language : String = Locale.preferredLanguages[0]
        if (language.contains("-")){
            language = language.components(separatedBy: "-")[0]
        }
        let baseUrl = (dict.object(forKey: "baseUrl") as! String).replacingOccurrences(of: "language", with: language)
        
        let url: URL = NSURL(string: baseUrl)! as URL
        
        do {
            let baseHTMLString = try String(contentsOf: url, encoding: .utf8)
            
            // remove work for a new version
            removeDestWWWContainer()
            // copy containers
            copyWWWContainer()
            
            do{
                let doc: Document = try SwiftSoup.parse(baseHTMLString)
                
                let liMenubars : Elements =  try! doc.select("#sectionNavigation > ul[role=\"menubar\"] li a")
                
                // parse the html than jQuery
                liMenubars.forEach { liMenu in
                    let text : String = try! liMenu.text()
                    let href : String = try! liMenu.attr("href")
                    let locationZones = try! doc.select(href)
                    
                    let offices = try! locationZones.select(".journal-content-article")
                    var finalCard = String()
                    let regex = "\\((.*?)\\)"
                    for (_, office) in offices.enumerated() {
                        
                        var card = NSLocalizedString("card", comment: "card")
                        card = card.replacingOccurrences(of: "<!-- IMG -->", with: try! office.select("svg").outerHtml())
                        card = card.replacingOccurrences(of: "<!-- NAME -->", with: try! office.select("h2").text())
                        card = card.replacingOccurrences(of: "<!-- DIRECTION -->", with: try! office.select("address").outerHtml())
                        card = card.replacingOccurrences(of: "<!-- MAPS -->", with: try! office.select("address > div[property!='telephone']").text())
                        var mainTel = try! office.select("address > div[property='telephone']").first()!.text()
                        let matches = matchesForRegexInText(regex: regex, text: mainTel)
                        if matches.count > 0{
                            mainTel = matches[0]
                        }
                        
                        card = card.replacingOccurrences(of: "<!-- TEL -->", with: mainTel)
                        card = card.replacingOccurrences(of: "<!-- COMPANY -->", with: try! office.select("div[property='name']").text())
                        
                        finalCard = finalCard+card
                        locations.append(card)
                    }
                    
                    var elementDict = [String : String]()
                    elementDict["id"] = "detail.html?name="+text+href
                    elementDict["name"] = text
                    
                    // build list page
                    replaceLocationsList(liMenubars: elementDict)
                    
                    //build details pages
                    createDetailFile(name: text, content: finalCard)
                    
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
            // If there isn't internet connection
            print("Error: \(error)")
            if(checkDist()){
                DispatchQueue.main.async() {
                    [unowned self] in
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                }
            }else{
                self.view.makeToast(NSLocalizedString("internet.connection", comment: "It's neccesary an internet connection"))
            }
        }
        
    }
    
    /**
 
     Replace the html list for the mains locations
     
     @param liMenubars Dictionary html parser.
     
     @return void
     
     */
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
    
    /**
     
     Replace the html detail for every continent
     
     @param name Name of the continent
     
     @param content Html content of the detail
     
     @return void
     
     */
    func createDetailFile(name: String, content: String){
    
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirectory.appendingPathComponent("dist/www/"+name+".html")
        let fileAboutURL = documentDirectory.appendingPathComponent("dist/www/about.html")
        let fileAboutContent = try! String(contentsOf: fileAboutURL)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let fileContent = fileAboutContent.replacingOccurrences(of: "<!-- CONTENT -->", with: content)
            if let fileHandle = try? FileHandle(forUpdating: fileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(fileContent.data(using: .utf8)!)
                fileHandle.closeFile()
            }
        } else {
            
            let fileContent = fileAboutContent.replacingOccurrences(of: "<!-- CONTENT -->", with: content)
            try! fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    /**
     Remove the work container
     
     */
    func removeDestWWWContainer(){
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = doumentDirectoryPath.appendingPathComponent("/dist")
        let filemgr = FileManager.default
        do {
            try filemgr.removeItem(atPath: destinationPath)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    /**
 
     Check if the work container has been created
 
     */
    func checkDist() -> Bool{
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = doumentDirectoryPath.appendingPathComponent("/dist")
        return FileManager.default.fileExists(atPath: destinationPath)
    }
    
    /**
 
    Copy asset folder to work container
 
     */
    func copyWWWContainer(){
        
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = doumentDirectoryPath.appendingPathComponent("/dist")
        
        let originPath = Bundle.main.resourcePath! + "/asset"
        
        let filemgr = FileManager.default
        do {
            try filemgr.copyItem(atPath: originPath, toPath: destinationPath)
            print("Move successful")
            
        } catch let error {
            print("Error: \(error)")
        }
    }

}
