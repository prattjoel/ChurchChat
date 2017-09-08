//
//  ChatTableDataSource.swift
//  ChurchChat
//
//  Created by Joel on 2/18/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import UIKit
import Firebase

//enum Messages {
//    case prayer
//    
//    case chat
//}


class ChatTableDataSource: NSObject, UITableViewDataSource {
//    
//    var chatMessages = [ChatMessage]()
//    
//    var prayerMessages = [ChatMessage]()
    
    var currentMessages = [ChatMessage]()
    
    var messageLists = [String: [ChatMessage]]()
    
    var chatRoom: String?
    
    
    
//    
//    var messages = Messages.chat
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "chatCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatCell
        
//        switch messages {
//        case .chat:
//           return checkForImage(messagesForCell: chatMessages, indexPath: indexPath, cell: cell, tableView: tableView)
//        case .prayer:
//           return checkForImage(messagesForCell: prayerMessages, indexPath: indexPath, cell: cell, tableView: tableView)
//            
//        }
        
        return checkForImage(indexPath: indexPath, cell: cell, tableView: tableView)

    }
    
    
    
    func checkForImage(indexPath: IndexPath, cell: ChatCell, tableView: UITableView) -> ChatCell {
        
        let message = currentMessages[indexPath.row]
        let name = message.name ?? "username"
        if let image = message.image {
            cell.chatImage.image = image
            cell.chatTitle.text = "From: \(name)"
            
        } else {
            
            if let photoUrl = message.url {
                cell.chatTitle.text = "From: \(name)"
                FIRStorage.storage().reference(forURL: photoUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    guard error == nil else {
                        print("error downloading image from photUrl: \(String(describing: error))")
                        return
                    }
                    
                    let messagePhoto = UIImage.init(data: data!, scale: 50)
                    if cell == tableView.cellForRow(at: indexPath) {
                        DispatchQueue.main.async {
                            cell.chatImage.image = messagePhoto
                            self.currentMessages[indexPath.row].image = messagePhoto
                            self.messageLists[self.chatRoom!]?[indexPath.row].image = messagePhoto
//                            let currentMessageList = self.getCurrentMessages()
//                            self.messageLists[currentMessageList]?[indexPath.row].image = messagePhoto
                            cell.setNeedsLayout()
                        }
                    }
                })
            } else {
                let text = message.text ?? "[message]"
                cell.chatTitle.text = name + ": "
                cell.chatMessage.text = text
            }
        }
        
        return cell
    }
    
    func setCurrentMessages(chatRoom: String) {
        
        self.chatRoom = chatRoom
        
        if let messages = messageLists[chatRoom] {
            currentMessages = messages
        } 
        
//        switch chatRoom {
//        case Constants.messages:
//            messages = Messages.chat
//            currentMessages = chatMessages
//        case Constants.prayerMessages:
//            messages = Messages.prayer
//            currentMessages = prayerMessages
//        default:
//            print("no messages could be set")
//        }
    }
    
    
    func updateDataSource(chatRoom: String, message: ChatMessage) {
        
        if (messageLists[chatRoom] != nil) {
            messageLists[chatRoom]!.append(message)
            currentMessages = messageLists[chatRoom]!
        } else {
            messageLists[chatRoom] = [message]
            currentMessages = messageLists[chatRoom]!
        }
        
//        if chatMessages.count == 0, prayerMessages.count == 0 {
//            messageLists[Constants.messages] = chatMessages
//            messageLists[Constants.prayerMessages] = prayerMessages
//        }
//        switch chatRoom {
//        case Constants.messages:
//            messages = Messages.chat
//            chatMessages.append(message)
//            currentMessages = chatMessages
//        case Constants.prayerMessages:
//            messages = Messages.prayer
//            prayerMessages.append(message)
//            currentMessages = prayerMessages
//        default:
//            print("no message found")
//        }
    }
    
//    func getCurrentMessages() -> String {
//        
//        switch messages {
//        case .chat:
//            return Constants.messages
//        case .prayer:
//            return Constants.prayerMessages
//            
//        }
//    }
    
}
