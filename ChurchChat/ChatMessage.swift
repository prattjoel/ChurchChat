//
//  ChatMessage.swift
//  ChurchChat
//
//  Created by Joel Pratt on 8/24/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Foundation
import Firebase

struct ChatMessage {
    var image: UIImage?
    var text: String?
    var name: String?
    var url: String?
    
    init(snapShot: FIRDataSnapshot) {
        
        let shotData = snapShot.value as! [String: String]
        
        if let snapShotText = shotData[Constants.text] {
            text = snapShotText
        }
        
        if let snapShotName = shotData[Constants.name] {
            name = snapShotName
        }
        if let snapUrl = shotData[Constants.photoUrl] {
            url = snapUrl
        }
    }
}
