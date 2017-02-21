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
    
    // MARK: - Login
    func login() -> UINavigationController {
        let loginVC = FUIAuth.defaultAuthUI()?.authViewController()
        
        return loginVC!
    }
    
    func databaseConfig() -> FIRDatabaseReference {
        let DBref = FIRDatabase.database().reference()
        
        return DBref
    }
}
