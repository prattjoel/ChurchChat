//
//  ChatTableDataSource.swift
//  ChurchChat
//
//  Created by Joel on 2/18/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import UIKit
import Firebase

enum Messages {
    case prayer
    
    case chat
}


class ChatTableDataSource: NSObject, UITableViewDataSource {
    
    var chatMessages = [ChatMessage]()
    
    var prayerMessages = [ChatMessage]()
    
    var currentMessages = [ChatMessage]()
    
    
    
    
    var messages = Messages.chat
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch messages {
        case .chat:
            return chatMessages.count
        case .prayer:
            return prayerMessages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "chatCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatCell
        
        switch messages {
        case .chat:
           return checkForImage(messages: chatMessages, indexPath: indexPath, cell: cell, tableView: tableView)
        case .prayer:
           return checkForImage(messages: prayerMessages, indexPath: indexPath, cell: cell, tableView: tableView)
            
        }
        
//        let message = messages[indexPath.row]
//        let name = message.name ?? "username"
//        if let image = message.image {
//            cell.chatImage.image = image
//            cell.chatTitle.text = "From: \(name)"
//
//        } else {
//            
//            if let photoUrl = message.url {
//                cell.chatTitle.text = "From: \(name)"
//                FIRStorage.storage().reference(forURL: photoUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
//                    guard error == nil else {
//                        print("erro downloading image from photUrl: \(String(describing: error))")
//                        return
//                    }
//                    
//                    let messagePhoto = UIImage.init(data: data!, scale: 50)
//                    if cell == tableView.cellForRow(at: indexPath) {
//                        DispatchQueue.main.async {
//                            cell.chatImage.image = messagePhoto
//                            self.messages[indexPath.row].image = messagePhoto
//                            cell.setNeedsLayout()
//                        }
//                    }
//                })
//            } else {
//                let text = message.text ?? "[message]"
//                cell.chatTitle.text = name + ": "
//                cell.chatMessage.text = text
//               // cell.textLabel?.text = name + ": " + text
//            }
//        }

        
        //return cell
    }
    
    
    
    func checkForImage( messages: [ChatMessage], indexPath: IndexPath, cell: ChatCell, tableView: UITableView) -> ChatCell {
        var messages = messages
        let message = messages[indexPath.row]
        let name = message.name ?? "username"
        if let image = message.image {
            cell.chatImage.image = image
            cell.chatTitle.text = "From: \(name)"
            
        } else {
            
            if let photoUrl = message.url {
                cell.chatTitle.text = "From: \(name)"
                FIRStorage.storage().reference(forURL: photoUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    guard error == nil else {
                        print("erro downloading image from photUrl: \(String(describing: error))")
                        return
                    }
                    
                    let messagePhoto = UIImage.init(data: data!, scale: 50)
                    if cell == tableView.cellForRow(at: indexPath) {
                        DispatchQueue.main.async {
                            cell.chatImage.image = messagePhoto
                            messages[indexPath.row].image = messagePhoto
                            cell.setNeedsLayout()
                        }
                    }
                })
            } else {
                let text = message.text ?? "[message]"
                cell.chatTitle.text = name + ": "
                cell.chatMessage.text = text
                // cell.textLabel?.text = name + ": " + text
            }
        }
        
        return cell
    }
    
    func setCurrentMessages(chatRoom: String) {
        switch chatRoom {
        case Constants.messages:
            messages = Messages.chat
            currentMessages = chatMessages
        case Constants.prayerMessages:
            messages = Messages.prayer
            currentMessages = prayerMessages
        default:
            print("no messages could be set")
        }
    }
    
    
    func updateDataSource(chatRoom: String, message: ChatMessage) {
        switch chatRoom {
        case Constants.messages:
            messages = Messages.chat
            chatMessages.append(message)
            currentMessages = chatMessages
        case Constants.prayerMessages:
            messages = Messages.prayer
            prayerMessages.append(message)
            currentMessages = prayerMessages
        default:
            print("no message found")
        }
    }
    
    
}
