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

class ChatVC: UIViewController, UINavigationControllerDelegate {
    
    // Mark: - Outlets
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var signInButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    let FBClient = FirebaseClient()
    var dbRef: FIRDatabaseReference!
    var dbHandle: FIRDatabaseHandle!
    var chatDatasource = ChatTableDataSource()
    var authListener: FIRAuthStateDidChangeListenerHandle!
    var user: FIRUser!
    var authUI: FUIAuth!
    var name = "anonymous"
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.dataSource = chatDatasource
        configAuth()
        
    }
    
    
    
    deinit {
        dbRef.child(Constants.messages).removeObserver(withHandle: dbHandle)
        FIRAuth.auth()?.removeStateDidChangeListener(authListener)
    }
    
    // MARK: - Configurations for Firebase
    
    func configAuth() {
        
        authUI = FUIAuth.defaultAuthUI()
        //        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        
        authListener = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            self.chatDatasource.messages.removeAll(keepingCapacity: false)
            self.chatTable.reloadData()
            
            if let currentUser = user {
                if self.user != currentUser {
                    self.user = currentUser
                    self.name = user!.email!.components(separatedBy: "@")[0]
                    self.databaseConfig()
                    self.isSignedIn(signedIn: true)
                }
            } else {
                self.presentLogin()
                self.isSignedIn(signedIn: false)
                
            }
        })
        
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
        
        var messageData = data
        messageData[Constants.name] = name
        
        dbRef.child(Constants.messages).childByAutoId().setValue(messageData)
    }
    
    func seeBottomMsg() {
        let bottomIndex = IndexPath(row: (chatDatasource.messages.count-1), section: 0)
        chatTable.scrollToRow(at: bottomIndex, at: .bottom, animated: true)
    }
    
    func presentLogin() {
        let loginVC = authUI!.authViewController()
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func isSignedIn(signedIn: Bool) {
        
        messageButton.isEnabled = signedIn
        addImage.isEnabled = signedIn
        chatTextField.isEnabled = signedIn
        if signedIn {
            signInButton.isEnabled = false
        }
    }
    
    //    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
    //        if error != nil {
    //            print("error with auth: \(error)")
    //        }
    //    }
    
    @IBAction func sendButton(_ sender: Any) {
        let _ = textFieldShouldReturn(chatTextField)
        chatTextField.text = ""
    }
    
    @IBAction func signIn(_ sender: Any) {
        presentLogin()
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
