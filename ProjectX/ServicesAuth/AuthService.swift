	//
//  AuthService.swift
//  ProjectX
//
//  Created by BrangerBriz Felipe on 26/04/18.
//  Copyright © 2018 BrangerBriz. All rights reserved.
//

import Foundation
import FirebaseAuth
 
typealias Completion = (_ errMsg: String?, _ data: Any?) -> Void
 
class AuthService {
    
    
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    func login(with email: String, and password: String, onComplete: Completion?) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
            
        }
    }
    
    func login(with credential: AuthCredential, onComplete: Completion?) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                if let user = user {
                    onComplete?(nil, user)
                }
            }
        })
    }
    
    func singup(with email: String, and password: String, onComplete: Completion?) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
            
        }
    }
    
    func anonymUser(onComplete: Completion?)  {
        Auth.auth().signInAnonymously() { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .invalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .wrongPassword:
                onComplete?("Invalid password", nil)
                break
            case .emailAlreadyInUse, .accountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use", nil)
                break
            case .userNotFound:
                onComplete?("Correct you email or sign up if you not have an account", nil)
                break
            case .weakPassword:
                onComplete?("Weak Password", nil)
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
    
}
