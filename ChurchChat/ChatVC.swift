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
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var signInButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    let FBClient = FirebaseClient()
    var dbRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
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
        //configAuth()
        
        authUI = FUIAuth.defaultAuthUI()
        
        FBClient.configAuth(authUI: authUI, chatDataSource: chatDatasource, chatTable: chatTable) { completion in
            if completion {
                
                    print("signed in")
                
            } else {
                self.presentLogin()
            }
        }
        
    }
    
    // Remove Listener
    
    deinit {
        dbRef.child(Constants.messages).removeObserver(withHandle: dbHandle)
        FIRAuth.auth()?.removeStateDidChangeListener(authListener)
    }
    
    // MARK: - Configurations for Firebase
    
    func configAuth() {
        
        authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        
        authListener = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            self.chatDatasource.messages.removeAll(keepingCapacity: false)
            self.chatTable.reloadData()
            
            if let currentUser = user {
                if self.user != currentUser {
                    self.user = currentUser
                    self.name = user!.email!.components(separatedBy: "@")[0]
                    self.FBClient.databaseConfig(chatDataSource: self.chatDatasource, chatTable: self.chatTable)
                   // self.seeBottomMsg()
                    self.storageConfig()
                    self.isSignedIn(signedIn: true)
                }
            } else {
                self.presentLogin()
                self.isSignedIn(signedIn: false)
                
            }
        })
        
    }
    
//    func databaseConfig() {
//        dbRef = FIRDatabase.database().reference()
//        dbHandle = dbRef.child(Constants.messages).observe(.childAdded, with: { (snapshot) in
//            
//            self.chatDatasource.messages.append(snapshot)
//            self.chatTable.insertRows(at: [IndexPath(row: self.chatDatasource.messages.count - 1, section: 0)], with: .automatic)
//            self.seeBottomMsg()
//        })
//        
//    }
    
    func storageConfig() {
        storageRef = FIRStorage.storage().reference()
    }
    
    //MARK: - Sending and receiving messages
    
//    func sendMessage(data: [String: String]) {
//        
//        var messageData = data
//        messageData[Constants.name] = name
//        
//        dbRef.child(Constants.messages).childByAutoId().setValue(messageData)
//    }
    
    func sendPhoto(data: Data) {
        let photoPath = "chat_photos/" + FIRAuth.auth()!.currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jeg"
        
        storageRef.child(photoPath).put(data, metadata: metadata) {(metadata, error) in
            if let error = error {
                print("error adding image to storage: \(error)")
                return
            }
            
            self.FBClient.sendMessage(data: [Constants.photoUrl: self.storageRef.child((metadata?.path)!).description])
        }
    }
    
    func seeBottomMsg() {
        let bottomIndex = IndexPath(row: (chatDatasource.messages.count-1), section: 0)
        chatTable.scrollToRow(at: bottomIndex, at: .bottom, animated: true)
    }
    
    
    // MARK: Login
    func presentLogin() {
        let loginVC = authUI!.authViewController()
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func isSignedIn(signedIn: Bool) {
        
        messageButton.isEnabled = signedIn
        addImage.isEnabled = signedIn
        chatTextField.isEnabled = signedIn
        signOutButton.isEnabled = signedIn
        if signedIn {
            signInButton.isEnabled = false
        } else {
            signInButton.isEnabled = true
        }
    }
    
    // MARK: Actions
    
    @IBAction func sendButton(_ sender: Any) {
        let _ = textFieldShouldReturn(chatTextField)
        chatTextField.text = ""
    }
    
    @IBAction func signIn(_ sender: Any) {
        presentLogin()
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        let auth = FIRAuth.auth()
        do {
            try auth?.signOut()
        } catch let errorForSignOut as NSError {
            print("Error signing out: \(errorForSignOut)")
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            
            present(picker, animated: true, completion: nil)
        } else {
            print("photo library not available")
        }
    }
    
}

// MARK: - ChatVC: UITextFieldDelegate

extension ChatVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !textField.text!.isEmpty {
            let data = [Constants.text: textField.text! as String]
            FBClient.sendMessage(data: data)
            
        }
        return true
    }
    
}

// MARK: - ChatVC: UIImagePickerControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate {
    // MARK: - Image Piicker Functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(photo, 0.8) {
            FBClient.sendPhoto(data: photoData)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
