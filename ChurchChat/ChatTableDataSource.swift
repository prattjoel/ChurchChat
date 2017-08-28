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
    
    var messages = [ChatMessage]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "chatCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatCell
        
        let message = messages[indexPath.row]
        let name = message.name ?? "username"
        if let image = message.image {
            cell.imageView?.image = image
        } else {
            
            if let photoUrl = message.url {
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
                            self.messages[indexPath.row].image = messagePhoto
                            cell.setNeedsLayout()
                        }
                    }
                })
            } else {
                let text = message.text ?? "[message]"
                cell.textLabel?.text = name + ": " + text
            }
        }

        
        return cell
    }
}
