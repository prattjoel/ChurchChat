//
//  CommunicationFormVC.swift
//  ChurchChat
//
//  Created by Joel on 4/29/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Eureka

class CommunicationFormVC: FormViewController {
    
    let FBClient = FirebaseClient.sharedFBClient
    var name: TextRow?
    var email: EmailRow?
    var message: TextAreaRow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(sendContactInfo)
        setupForm()
    }
    
    func setupForm() {
        form +++ Section("Contact")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "Enter name here"
                self.name = row
            }
            <<< EmailRow(){
                $0.title = "Email"
                $0.placeholder = "Enter email here"
                self.email = $0
            }
            
            +++ Section("Communication")
            <<< TextAreaRow(){
                $0.title = "Message"
                $0.placeholder = "Enter your message here"
                self.message = $0
            }
            
            +++ Section()
            <<< ButtonRow(){
                $0.title = "Tap to send contact info"
                }
                
                .onCellSelection({ (cell, row) in
                    
                    if let user = self.name?.value, let userEmail = self.email?.value, let userMessage = self.message?.value {
                        
                        let contactInfo = ContactInfo(name: user, email: userEmail, message: userMessage)
                        
                        self.FBClient.sendUserContact(user: contactInfo)
                        
                        // print("name: \(user) \n email: \(userEmail) \n message: \(userMessage)")
                    } else {
                        print("form not filled out")
                    }
                   
                })
    }
    
    @objc func sendContactInfo() {
        
    }
}
