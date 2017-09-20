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
    
    static var sharedInstance = ChatMessageStore()
    
    var messageStore = [ChatRoom]()
    var roomNames = [String]()
    var currentChatroom: ChatRoom?
    
    // Get the current chatRoom based on its name.
    mutating func getCurrentRoom(roomName: String?) -> ChatRoom? {
        
        for room in messageStore {
            if room.name == roomName {
                currentChatroom = room
                return room
            }
        }
        return nil
    }
    
    // Add chatRoom to the messageStore
    mutating func addChatroom(room: ChatRoom) {
        messageStore.append(room)
        roomNames.append(room.name)
        currentChatroom = room
    }
    
    // Add message to the current ChatRoom
    mutating func updateRoom(message: ChatMessage, name: String) {
        var index = 0
        for room in messageStore {
            if room.name == name {
                messageStore[index].addMessge(message: message)
                currentChatroom = messageStore[index]
              //  room.addMessge(message: message)
            }
            index += 1
        }
    }
    
    // Get the names of rooms in the store
    mutating func getRoomNames() -> [String] {
        for room in messageStore {
            roomNames.append(room.name)
        }
        
        return roomNames
    }
    
    // Check if a ChatRoom exists in the store
    func isInStore(room: String) -> Bool {
        if roomNames.contains(room) {
            return true
        } else {
            return false
        }
    }
    
    // Add UIImage to ChatMessage
    
    mutating func updateMessageWithImage(name: String, index: Int, image: UIImage) {
        var storeIndex = 0
        for room in messageStore {
            if room.name == name {
                messageStore[storeIndex].chatRoom[index].image = image
                currentChatroom = messageStore[storeIndex]
            }
            storeIndex += 1
        }
    }
}
