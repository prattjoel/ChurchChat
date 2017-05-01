//
//  CommunicationFormVC.swift
//  ChurchChat
//
//  Created by Joel on 4/29/17.
//  Copyright © 2017 Joel Pratt. All rights reserved.
//

import Eureka

class CommunicationFormVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
//        form +++ Section("Section1")
//            <<< TextRow(){ row in
//                row.title = "Name"
//                row.placeholder = "Enter text here"
//            }
//            <<< PhoneRow(){
//                $0.title = "Phone Number"
//                $0.placeholder = "And numbers here"
//            }
//            +++ Section("Section2")
//            <<< DateRow(){
//                $0.title = "Date Row"
//                $0.value = Date(timeIntervalSinceReferenceDate: 0)
//        }
    }
    
    func setupForm() {
        form +++ Section("Contact")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "Enter name here"
        }
            <<< EmailRow(){
                $0.title = "Email"
                $0.placeholder = "Enter email here"
        }
        
        +++ Section("Communication")
            <<< TextAreaRow(){
                $0.title = "Message"
                $0.placeholder = "Enter your message here"
        }
    }
}
