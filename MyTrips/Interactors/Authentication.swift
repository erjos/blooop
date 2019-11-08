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
class FirebaseAuthUtil: AuthUtilProtocol {
    //with current implementation this viewConroller mus conform to the FUIAuthDelegate protocol provided by Firebase
    static func getAuthViewController(delegate: UIViewController) -> UIViewController? {
        let authUI = FUIAuth.defaultAuthUI()
        guard let fuiAuth = delegate as? FUIAuthDelegate else {
            fatalError("ViewController does not conform to FUIAuthDelegate protocol")
        }
        authUI?.delegate = fuiAuth
        //define accepted sign in methods
        let providers: [FUIAuthProvider] = [FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!), FUIEmailAuth()]
        authUI?.providers = providers
        return authUI?.authViewController()
    }
    
    static func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

//FirebaseInteractor will define specific firebase related methods
protocol AuthUtilProtocol {
    //retrieve the AuthViewController
    static func getAuthViewController(delegate: UIViewController)->UIViewController?
    //returns current userID
    static func getUserId() -> String?
    //return true if there is a current user
    static func isUserLoggedIn() -> Bool
}
