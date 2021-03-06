//
//  ChatCell.swift
//  ChurchChat
//
//  Created by Joel Pratt on 8/17/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatCell: UITableViewCell {
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var chatMessage: UILabel!
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    
    var imageCount = 0
    var messages = [UIImage]()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.chatImage.image = nil
        self.chatMessage.text = nil
        self.chatTitle.text = nil
    }
    
    func updateUI(message: ChatMessage, indexPath: IndexPath, tableView: UITableView, room: String) {
        var imageCounter = 0
        let name = message.name ?? "username"
        if let image = message.image {
            chatImage.image = image
            chatTitle.text = "From: \(name)"
            
        } else {
            
            if let photoUrl = message.url {
                imageCount += 1
               // print("Images checked for: \(imageCount)")
                imageIndicator.isHidden = false
                imageIndicator.startAnimating()
                chatTitle.text = "From: \(name)"
                Storage.storage().reference(forURL: photoUrl).getData(maxSize: INT64_MAX, completion: { (data, error) in
                    guard error == nil else {
                        print("error downloading image from photUrl: \(String(describing: error))")
                        return
                    }
                    
                    let messagePhoto = UIImage.init(data: data!, scale: 50)
                    //self.imageCount += 1
                    self.messages.append(messagePhoto!)
                    //print("Number of images: \(self.messages.count)")
                    //print("\(self.imageCount) image retrieved")
                    if self == tableView.cellForRow(at: indexPath) {
                        DispatchQueue.main.async {
                            self.imageIndicator.stopAnimating()
                            self.chatImage.image = messagePhoto!
                            ChatMessageStore.sharedInstance.updateMessageWithImage(name: room, index: indexPath.row, image: messagePhoto!)
                            self.setNeedsLayout()
                            imageCounter += 1
                            print("\(imageCounter). Image added")
                        }
                    }
                })
            } else {
                let text = message.text ?? "[message]"
                chatTitle.text = name + ": "
                chatMessage.text = text
            }
        }
    }
}
