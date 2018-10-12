//
//  LoginViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/3/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        //
       
    }
    
    @IBAction func loginButton(_ sender: Any) {
        guard let email = emailTextField.text,let password = passwordTextField.text else{
            print("Form is not valid")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error)
                self.alertWarning(title: "Failure", message: "The password is invalid or the user does not have a password")
                return
            }
            //succesfully logged in
            let defaults = UserDefaults.standard
            if let flag = defaults.string(forKey: "name")?.elementsEqual(""){
                
            }else{
                defaults.set(email, forKey: "email")
                defaults.set("", forKey: "name")
            }
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "productsViewController")
            self.present(viewContr!, animated: true, completion: nil)
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func alertWarning(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
