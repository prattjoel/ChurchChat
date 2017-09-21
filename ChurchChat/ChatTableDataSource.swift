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
    
    var imageCheck = 0
    
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
        
        imageCheck += 1
        
        let message = messages.chatRoom[indexPath.row]
        cell.updateUI(message: message, indexPath: indexPath, tableView: tableView, room: chatRoom!)
        
        print("Images checked for: \(imageCheck)")
        return cell
    }
}
