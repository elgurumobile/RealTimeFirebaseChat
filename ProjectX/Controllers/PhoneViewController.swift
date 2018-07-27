//
//  PhoneViewController.swift
//  ProjectX
//
//  Created by Felipe Aragon on 7/05/18.
//  Copyright © 2018 BrangerBriz. All rights reserved.
//

import UIKit
import Firebase

class PhoneViewController: UIViewController {

    
    @IBOutlet weak var codPaisTextField: CustomTextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerPhone(_ sender: Any) {
        if let codpais = codPaisTextField.text, let phone = phoneTextField.text, codpais.count > 0 , phone.count > 0{
            PhoneAuthProvider.provider().verifyPhoneNumber("\(codpais)\(phone)", uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    self.alertError(error.localizedDescription)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                self.openDialogCodVerification()
            }
        }
    }
    
    func alertError(_ errMsg: String?) {
        let authAlert = UIAlertController(title: "Error Authentication", message: errMsg, preferredStyle: .alert)
        authAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(authAlert, animated: true, completion: nil)
    }
    
    func openDialogCodVerification(){
        
        let alertController = UIAlertController(title: "Ingresar Código Verificación", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "COD SMS"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { alert -> Void in
            
            self.getCredential(codVerification: alertController.textFields![0].text)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getCredential(codVerification :String?)  {
        if let verificationCode = codVerification , let verificationID = UserDefaults.standard.string(forKey: "authVerificationID"){
            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,verificationCode: verificationCode)
            AuthService.instance.login(with: credential, onComplete: { (error, user) in
                guard error == nil else {
                    self.alertError(error)
                    return
                }
                
                self.performSegue(withIdentifier: "roomChat",sender: user)
            })
            
        }
    }
}
