//
//  DonateVC.swift
//  ChurchChat
//
//  Created by Joel on 5/4/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import UIKit

class DonateVC: UIViewController {
    
    @IBAction func donate(_ sender: Any) {
        let app = UIApplication.shared
        
        let urlString = "http://bit.ly/newdaygiving"
        let url = URL(string: urlString)
        
        app.open(url!, options: [:], completionHandler: nil)
    }

}
