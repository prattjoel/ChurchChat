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
    let snapShot: FIRDataSnapshot
    let image: UIImage
    let text: String
    let name: String
    let url: String
}
