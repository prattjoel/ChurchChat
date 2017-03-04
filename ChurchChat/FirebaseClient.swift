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
    
    var dbRef: FIRDatabaseReference!
    
    
    // MARK: - Login
    func login() -> UINavigationController {
        let loginVC = FUIAuth.defaultAuthUI()?.authViewController()
        
        return loginVC!
    }
    
    func databaseConfig() {
        dbRef = FIRDatabase.database().reference()

    }
    
    func sendMessage(data: [String: String]) {
        databaseConfig()
        dbRef.child("messages").childByAutoId().setValue(data)
    }
    
    
}
