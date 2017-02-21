//
//  ChatTableDataSource.swift
//  ChurchChat
//
//  Created by Joel on 2/18/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import UIKit
import Firebase

class ChatTableDataSource: NSObject, UITableViewDataSource {
    
    var messages = [FIRDataSnapshot]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "chatCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) 
        
        return cell
    }
}