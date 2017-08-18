//
//  ChatCell.swift
//  ChurchChat
//
//  Created by Joel Pratt on 8/17/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
    }
}
