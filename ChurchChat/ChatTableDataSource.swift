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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatCell
        
        let snapshot = messages[indexPath.row]
        let message = snapshot.value as! [String: String]
        let name = message[Constants.name] ?? "username"
        
        if let photoUrl = message[Constants.photoUrl] {
            cell.textLabel?.text = "From: \(name)"
            FIRStorage.storage().reference(forURL: photoUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                guard error == nil else {
                    print("erro downloading image from photUrl: \(String(describing: error))")
                    return
                }
                
                let messagePhoto = UIImage.init(data: data!, scale: 50)
                if cell == tableView.cellForRow(at: indexPath) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = messagePhoto
                        cell.setNeedsLayout()
                    }
                }
            })
        } else {
            let text = message[Constants.text] ?? "[message]"
            cell.textLabel?.text = name + ": " + text
        }
        
        return cell
    }
}
