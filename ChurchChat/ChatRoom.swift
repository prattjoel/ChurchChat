//
//  ChatRoom.swift
//  ChurchChat
//
//  Created by Joel Pratt on 9/13/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Foundation

struct ChatRoom {
    var chatRoom = [ChatMessage]()
    var name: String
    var numberOfMessages: Int
    
    init (message: ChatMessage, chatRoomName: String) {
        name = chatRoomName
        chatRoom.append(message)
        numberOfMessages = chatRoom.count
        
    }
    
    mutating func addMessge(message: ChatMessage){
        chatRoom.append(message)
        numberOfMessages = chatRoom.count
        
    }
}
