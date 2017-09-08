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
    @IBOutlet var keyboardDismissTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var messageTextStack: UIStackView!
    
    // MARK: - Properties
    
    let FBClient = FirebaseClient.sharedFBClient
    var chatDatasource = ChatTableDataSource()
    var keyboardIsVisible = false
    var chatRoom: String?
    
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatRoom = Constants.messages
        chatTable.dataSource = chatDatasource
        chatTable.rowHeight = UITableViewAutomaticDimension
         chatTable.estimatedRowHeight = 120
    
        chatTable.reloadData()
        
        chatTextField.delegate = self
        
        FBClient.configAuth(chatDataSource: chatDatasource, chatTable: chatTable, chatRoom: chatRoom!) { completion in
            if completion {
                
                self.isSignedIn(signedIn: true)
            } else {
                self.presentLogin()
                self.isSignedIn(signedIn: false)
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // Remove Listener
    
    deinit {
        FBClient.dbRef.child(Constants.messages).removeObserver(withHandle: FBClient.dbHandle)
        FIRAuth.auth()?.removeStateDidChangeListener(FBClient.authListener)
    }
    
    
    
    // MARK: Login
    func presentLogin() {
        let loginVC = FBClient.authUI!.authViewController()
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func isSignedIn(signedIn: Bool) {
        
        messageButton.isEnabled = signedIn
        addImage.isEnabled = signedIn
        chatTextField.isEnabled = signedIn
        signOutButton.isEnabled = signedIn
        keyboardDismissTapGesture.isEnabled = false
        if signedIn {
            signInButton.isEnabled = false
            
        } else {
            signInButton.isEnabled = true
        }
    }
    
    // MARK: Actions
    
    @IBAction func sendButton(_ sender: Any) {
        let _ = textFieldShouldReturn(chatTextField)
        
    }
    
    @IBAction func dismissKeyboardOnScreenTap(_ sender: Any) {
        
        chatTextField.resignFirstResponder()
        
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
    
    @IBAction func chooseRoom(_ sender: UIBarButtonItem) {
        if chatRoom == Constants.messages {
            chatRoom = Constants.prayerMessages
        } else {
            chatRoom = Constants.messages
        }
        
        chatDatasource.setCurrentMessages(chatRoom: chatRoom!)
        
        if chatDatasource.messageLists[chatRoom!] == nil {
            chatDatasource.currentMessages.removeAll()
            //chatTable.numberOfRows(inSection: 0)
            FBClient.databaseConfig(chatDataSource: chatDatasource, chatTable: chatTable, chatRoom: chatRoom!)
        }
        
        chatTable.reloadData()
        
    }
}

// MARK: - ChatVC: UITextFieldDelegate

extension ChatVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !textField.text!.isEmpty {
            let data = [Constants.text: textField.text! as String]
            FBClient.sendMessage(data: data, chatRoom: chatRoom!)
            textField.resignFirstResponder()
            chatTextField.text = ""
        }
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        
        keyboardDismissTapGesture.isEnabled = true
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0 {
                let tabBarHeight = self.tabBarController?.tabBar.frame.height
                let totalSize = keyboardSize.height - tabBarHeight!
                self.chatTable.frame.origin.y -= totalSize
                self.messageTextStack.frame.origin.y -= totalSize
            }
            
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        keyboardDismissTapGesture.isEnabled = false
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.chatTable.frame.origin.y += keyboardSize.height
                self.messageTextStack.frame.origin.y -= keyboardSize.height
            }
        }
    }
}

// MARK: - ChatVC: UIImagePickerControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate {
    
    // MARK: - Image Piicker Functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(photo, 0.8) {
            FBClient.sendPhoto(data: photoData, chatRoom: chatRoom!)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

