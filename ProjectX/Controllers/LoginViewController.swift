//
//  ViewController.swift
//  ProjectX
//
//  Created by BrangerBriz Felipe on 26/04/18.
//  Copyright © 2018 BrangerBriz. All rights reserved.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

fileprivate let minimalUsernameLength = 5
fileprivate let minimalPasswordLength = 5

class LoginViewController: UIViewController {

    var loginMode = false
    
    @IBOutlet weak var singupBtn: CustomButton!
    @IBOutlet weak var emailTF: CustomTextField!
    @IBOutlet weak var passwordTF: CustomTextField!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.delegate = self
        passwordTF.delegate = self
        
        let usernameValid = emailTF.rx.text.orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1) // without this map would be executed once for each binding, rx is stateless by default
        
        let passwordValid = passwordTF.rx.text.orEmpty
            .map { $0.count >= minimalPasswordLength }
            .share(replay: 1)
        
        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)
        
        everythingValid
            .bind(to: singupBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        singupBtn.rx.tap
        .subscribe({ [weak self] _ in self?.loginIn() })
        .disposed(by: disposeBag)
       
        refreshView();
    }

    func refreshView(){
        if (loginMode) {
            singupBtn.setTitle("Login", for: UIControlState.normal)
        } else {
            singupBtn.setTitle("Sing Up", for: UIControlState.normal)
        }
    }
    
    
    func loginIn()  {
        if (loginMode) {
            AuthService.instance.login(with: emailTF.text!, and: passwordTF.text!, onComplete: onAuthComplete)
        } else {
            AuthService.instance.singup(with: emailTF.text!, and: passwordTF.text!, onComplete: onAuthComplete)
        }
    }
    
    func onAuthComplete(_ errMsg: String?, _ data: Any?) -> Void {
        guard errMsg == nil else {
            let authAlert = UIAlertController(title: "Error Authentication", message: errMsg, preferredStyle: .alert)
            authAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(authAlert, animated: true, completion: nil)
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
}
