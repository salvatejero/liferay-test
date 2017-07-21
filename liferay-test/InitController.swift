//
//  InitController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 18/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import UIKit
import CoreLocation


class InitController: BaseController {
    
    var locations : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "base", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            
            let app = AppModule()
            let baseUrl = dict.object(forKey: "baseUrl") as! String
            if let locations = app.prepareApplication(baseUrl: baseUrl){
                self.locations = locations
                DispatchQueue.main.async() {
                    [unowned self] in
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                }
            }else{
                if(app.checkDist()){
                    DispatchQueue.main.async() {
                        [unowned self] in
                        self.performSegue(withIdentifier: "goToMain", sender: self)
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("internet.connection", comment: "It's neccesary an internet connection"))
                }
            }
            
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
    
    

}
