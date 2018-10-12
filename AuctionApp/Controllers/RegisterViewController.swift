//
//  RegisterViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/3/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func registerButton(_ sender: Any) {
        guard let email = emailTextField.text,let password = passwordTextField.text else{
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print("error")
                self.alertWarning(title: "Failure", message: "Your credentials are too weak")
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            self.alertWarning(title: "Succesfull", message: "Your account has just been created")
            let ref = Database.database().reference()
            let values = ["email" : email] as [String : Any]
            ref.child("users").child(uid).setValue(values)
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
    
    func alertWarning(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
