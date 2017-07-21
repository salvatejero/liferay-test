//
//  BaseController.swift
//  liferay-test
//
//  Created by Salvador Tejero on 20/7/17.
//  Copyright © 2017 Salvador Tejero. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI


class  BaseController: UIViewController, CNContactViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

    }
    
    /**
     Create a contact with the info
     
     @param contact: CNMutableContact new contact
     
     */
    func contactLink(contact: CNMutableContact) {
        
        let controller = CNContactViewController(forNewContact: contact)
        controller.delegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.navigationController?.dismiss(animated: true)
    }


}

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }

}


extension URL {
    func valueOf(queryParamaterName: String) -> String? {
        
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

