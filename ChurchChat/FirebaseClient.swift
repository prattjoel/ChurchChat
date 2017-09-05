//
//  FireBaseClient.swift
//  ChurchChat
//
//  Created by Joel on 2/18/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class FirebaseClient {
    
    // MARK: Properties
    
    var dbRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var dbHandle: FIRDatabaseHandle!
    var authListener: FIRAuthStateDidChangeListenerHandle!
    var user: FIRUser!
    var name = "anonymous"
    var authUI: FUIAuth!
    
    
    
    // MARK: - Firebase Config Methods
    
    func configAuth(chatDataSource: ChatTableDataSource, chatTable: UITableView, chatRoom: String, completion: @escaping (Bool)->Void) {
        
        authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        
        authListener = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            chatDataSource.messages.removeAll(keepingCapacity: false)
            chatTable.reloadData()
            
            if let currentUser = user {
                if self.user != currentUser {
                    self.user = currentUser
                    self.name = user!.email!.components(separatedBy: "@")[0]
                    self.databaseConfig(chatDataSource: chatDataSource, chatTable: chatTable, chatRoom: chatRoom)
                    
                    self.storageConfig()
                    completion(true)
                }
            } else {
                completion(false)
                
            }
        })
        
    }
    
    func databaseConfig(chatDataSource: ChatTableDataSource, chatTable: UITableView, chatRoom: String) {
        dbRef = FIRDatabase.database().reference()

        dbHandle = dbRef.child(chatRoom).observe(.childAdded, with: { (snapshot) in
            
          //  chatDataSource.messages.removeAll()
            
            let chatMessage = ChatMessage.init(snapShot: snapshot)
            chatDataSource.messages.append(chatMessage)
        
            chatTable.insertRows(at: [IndexPath(row: chatDataSource.messages.count - 1, section: 0)], with: .automatic)
            self.seeBottomMsg(chatDataSource: chatDataSource, chatTable: chatTable)
        })
        
    
        
    }
    
    
    func storageConfig() {
        storageRef = FIRStorage.storage().reference()
    }
    
    // MARK: - Firebase Data sending methods
    
    func sendMessage(data: [String: String], chatRoom: String) {
        
        var messageData = data
        // print(data)
        messageData[Constants.name] = name
        
        dbRef.child(chatRoom).childByAutoId().setValue(messageData)
    }
    
    func sendUserContact(user: ContactInfo) {
        let contactData = [
            Constants.name: user.name,
            Constants.email: user.email,
            Constants.contactMessage: user.message
        ]
        
        dbRef.child(Constants.contactInfo).childByAutoId().setValue(contactData)
    }
    
    
    func sendPhoto(data: Data, chatRoom: String) {
        let photoPath = "chat_photos/" + FIRAuth.auth()!.currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jeg"
        
        storageRef.child(photoPath).put(data, metadata: metadata) {(metadata, error) in
            if let error = error {
                print("error adding image to storage: \(error)")
                return
            }
            
            self.sendMessage(data: [Constants.photoUrl: self.storageRef.child((metadata?.path)!).description], chatRoom: chatRoom)
        }
    }
    
    func seeBottomMsg(chatDataSource: ChatTableDataSource, chatTable: UITableView) {
        let bottomIndex = IndexPath(row: (chatDataSource.messages.count-1), section: 0)
        chatTable.scrollToRow(at: bottomIndex, at: .bottom, animated: true)
    }
    
    
}

extension FirebaseClient {
    static let sharedFBClient = FirebaseClient()
}
