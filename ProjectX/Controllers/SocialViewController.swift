//
//  SocialViewController.swift
//  ProjectX
//
//  Created by BrangerBriz Felipe on 26/04/18.
//  Copyright © 2018 BrangerBriz. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

class SocialViewController: UIViewController,GIDSignInUIDelegate {

    enum AuthProvider: Int {
        case email = 1
        case facebook
        case google
        case twitter
        case phone
        case anonym
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signIn(_ sender: UIButton) {
        
        switch sender.tag {
            case AuthProvider.email.rawValue:
                self.performSegue(withIdentifier: "loginSegue",sender: true)
            case AuthProvider.facebook.rawValue:
                loginFacebook();
            case AuthProvider.google.rawValue:
                loginGoogle()
            case AuthProvider.twitter.rawValue:
                loginTwitter()
            case AuthProvider.anonym.rawValue:
                loginAnonym()
            default:()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertError(_ errMsg: String?) {
        let authAlert = UIAlertController(title: "Error Authentication", message: errMsg, preferredStyle: .alert)
        authAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(authAlert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToSocialViewcontroller(segue:UIStoryboardSegue) { }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "loginSegue"){
            let viewcontroller = segue.destination as! LoginViewController
            viewcontroller.loginMode = sender as! Bool
        }
        
        if(segue.identifier == "roomChat"){
            let viewcontroller = segue.destination as! RoomChatViewController
            viewcontroller.user = sender as? User
        }
    }
}


extension SocialViewController{
    
    func loginFacebook()  {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
            if let error = error {
                print(error.localizedDescription);
                self.alertError("Unable to authenticate with facebook")
            } else if result!.isCancelled {
                self.alertError("User cancel facebook authentication")
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                AuthService.instance.login(with: credential, onComplete: self.onAuthComplete)
            }
        })
    }
    
    func loginGoogle()  {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginTwitter()  {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                if let authToken = session?.authToken, let authTokenSecret = session?.authTokenSecret{
                    
                    let credential = TwitterAuthProvider.credential(withToken: authToken, secret: authTokenSecret)
                    AuthService.instance.login(with: credential, onComplete: self.onAuthComplete)
                }
            } else {
                self.alertError(error?.localizedDescription)
            }
        })
    }
    
    func loginAnonym()  {
        AuthService.instance.anonymUser(onComplete: self.onAuthComplete)
    }

    func onAuthComplete(_ errMsg: String?, _ data: Any?) -> Void {
        guard errMsg == nil else {
            alertError(errMsg)
            return
        }
        self.performSegue(withIdentifier: "roomChat",sender: data)
    }
}



