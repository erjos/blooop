//
//  AuthenticationInteractor.swift
//  MyTrips
//
//  Created by Ethan Joseph on 6/20/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import Foundation
import FirebaseUI
import FirebaseAuth

//FirebaseInteractor will handle specific firebase related method calls
class FirebaseInteractor: FirebaseAuthProtocol {
    func getAuthViewController(delegate: FUIAuthDelegate) -> UIViewController? {
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = delegate
        //This defines your accepted sign in methods
        let providers: [FUIAuthProvider] = [FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!), FUIEmailAuth()]
        authUI?.providers = providers
        
        //deliver authViewController
        return authUI?.authViewController()
    }
    
    //return true if there is a current user
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

//AuthenticationInteractor will handle general auth specifc methods that can be abstracted away from the Firebase library
class AuthInteractor : AuthenticationProtocol {
    func signIn() {
        //dont need this right now because firebase handles everything
    }
    
    func signOut() {
        //sign out
    }
}

//FirebaseInteractor will define specific firebase related methods
protocol FirebaseAuthProtocol {
    func getAuthViewController(delegate: FUIAuthDelegate)->UIViewController?
    func isUserLoggedIn() -> Bool
}

//AuthenticationProtocol will define general Auth specifc methods that can be abstracted away from the Firebase library
protocol AuthenticationProtocol {
    func signIn()
    func signOut()
}
