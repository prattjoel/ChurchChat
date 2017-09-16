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
    
    var currentChatRoom: ChatRoom?
    
    var messageLists = [String: [ChatMessage]]()
    
    var chatRoom: String?
    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        if let messageCount = ChatMessageStore.sharedInstance.currentChatroom?.numberOfMessages {
                return messageCount
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "chatCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatCell
        cell.imageIndicator.isHidden = true
        cell.imageIndicator.hidesWhenStopped = true
        return checkForImage(indexPath: indexPath, cell: cell, tableView: tableView)!

    }
    
    // MARK: - TableView Helper Methods
    
    // Populate cell with image and/or text
    func checkForImage(indexPath: IndexPath, cell: ChatCell, tableView: UITableView) -> ChatCell? {
        
        guard let messages = ChatMessageStore.sharedInstance.currentChatroom else {
            print("no messages found in currentChatroom")
            return nil
        }
       
        let message = messages.chatRoom[indexPath.row]
        let name = message.name ?? "username"
        if let image = message.image {
            cell.chatImage.image = image
            cell.chatTitle.text = "From: \(name)"
            
        } else {
            
            if let photoUrl = message.url {
                cell.imageIndicator.isHidden = false
                cell.imageIndicator.startAnimating()
                cell.chatTitle.text = "From: \(name)"
                FIRStorage.storage().reference(forURL: photoUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    guard error == nil else {
                        print("error downloading image from photUrl: \(String(describing: error))")
                        return
                    }
                    
                    let messagePhoto = UIImage.init(data: data!, scale: 50)
                    if cell == tableView.cellForRow(at: indexPath) {
                        DispatchQueue.main.async {
                            cell.imageIndicator.stopAnimating()
                            self.addImageToMessage(image: messagePhoto!, cell: cell, indexPath: indexPath)
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
    
    // Add UIImage to cell in the appropriate message array
    func addImageToMessage(image: UIImage, cell: ChatCell, indexPath: IndexPath) {
        cell.chatImage.image = image
        var index = 0
        for room in ChatMessageStore.sharedInstance.messageStore {
            if room.name == chatRoom {
                ChatMessageStore.sharedInstance.messageStore[index].chatRoom[indexPath.row].image = image
                ChatMessageStore.sharedInstance.currentChatroom = ChatMessageStore.sharedInstance.messageStore[index]
            } else {
                print("Could not add image to message in message store")
            }
            index += 1
        }
        cell.setNeedsLayout()
    }
}
