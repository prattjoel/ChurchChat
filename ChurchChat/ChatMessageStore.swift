//
//  ChatMessageStore.swift
//  ChurchChat
//
//  Created by Joel Pratt on 9/12/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Foundation
import UIKit

struct ChatMessageStore {
    var messageStore: [String: [ChatMessage]]
    
    var currentMessages: [ChatMessage]
    
    var chatRoom: String?
    
    mutating func updateMessageStore(chatRoom: String, message: ChatMessage) {
        
        if (messageStore[chatRoom] != nil) {
            messageStore[chatRoom]?.append(message)
            currentMessages = messageStore[chatRoom]!
        } else {
            messageStore[chatRoom] = [message]
            currentMessages = messageStore[chatRoom]!
        }
    }
    
    mutating func setCurrentMessages(chatRoom: String) {
        
        self.chatRoom = chatRoom
        
        if let messages = messageStore[chatRoom] {
            currentMessages = messages
        }
    }
    
    mutating func addImageToMessage(image: UIImage, cell: ChatCell, indexPath: IndexPath) {
        cell.chatImage.image = image
        currentMessages[indexPath.row].image = image
        messageStore[chatRoom!]?[indexPath.row].image = image
        cell.setNeedsLayout()
    }
    
}
