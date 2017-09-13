//
//  ChatRoom.swift
//  ChurchChat
//
//  Created by Joel Pratt on 9/13/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Foundation

struct ChatRoom {
    var chatRoom: [ChatMessage]
    var roomName: String
    var numberOfMessages: Int
    
    init (message: ChatMessage, chatRoomName: String) {
        chatRoom = [message]
        roomName = chatRoomName
        numberOfMessages = chatRoom.count
    }
}
