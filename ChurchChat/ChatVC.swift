//
//  ChatVC.swift
//  ChurchChat
//
//  Created by Joel on 2/18/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class ChatVC: UIViewController, UINavigationControllerDelegate, FUIAuthDelegate {
    
    // Mark: - Outlets
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTable: UITableView!
    
    // MARK: - Properties
    
    let FBClient = FirebaseClient()
    var signedIn = false
    var dbRef: FIRDatabaseReference!
    var dbHandle: FIRDatabaseHandle!
    var chatDatasource = ChatTableDataSource()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configAUth()
        chatTable.dataSource = chatDatasource
    }
    
    deinit {
        dbRef.child(Constants.messages).removeObserver(withHandle: dbHandle)
    }
    
    // MARK: - Configurations for Firebase
    
    func configAUth() {
        
        if !signedIn {
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
            authUI?.providers = providers
            
            let loginVC = authUI!.authViewController()
            self.present(loginVC, animated: true, completion: nil)
            
            signedIn = true
        }
    }
    
    func databaseConfig() {
        dbRef = FIRDatabase.database().reference()
        dbHandle = dbRef.child(Constants.messages).observe(.childAdded, with: { (snapshot) in
            
            self.chatDatasource.messages.append(snapshot)
            self.chatTable.insertRows(at: [IndexPath(row: self.chatDatasource.messages.count - 1, section: 0)], with: .automatic)
            self.seeBottomMsg()
        })
        
    }
    
    //MARK: - Sending and receiving messages
    
    func sendMessage(data: [String: String]) {
        databaseConfig()
        dbRef.child(Constants.messages).childByAutoId().setValue(data)
    }
    
    func seeBottomMsg() {
        let bottomIndex = IndexPath(row: (chatDatasource.messages.count-1), section: 0)
        chatTable.scrollToRow(at: bottomIndex, at: .bottom, animated: true)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if error != nil {
            print("error with auth: \(error)")
        }
    }
    
    @IBAction func sendButton(_ sender: Any) {
        let _ = textFieldShouldReturn(chatTextField)
        chatTextField.text = ""
    }
    
    @IBOutlet weak var addImage: UIButton!
    
}

extension ChatVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !textField.text!.isEmpty {
            let data = [Constants.text: textField.text! as String]
            sendMessage(data: data)
            
        }
        return true
    }
    
}
