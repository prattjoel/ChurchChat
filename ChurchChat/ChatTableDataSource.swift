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
                            cell.chatImage.image = messagePhoto!
                            ChatMessageStore.sharedInstance.updateMessageWithImage(name: self.chatRoom!, index: indexPath.row, image: messagePhoto!)
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
}
