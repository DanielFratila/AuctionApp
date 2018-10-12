//
//  BidModalViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/9/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Firebase

class BidModalViewController: UIViewController,UITextFieldDelegate{
    @IBOutlet weak var amount: UITextField!
    var products = [Product]()
    var users = [User]()
    var indexPathOfProduct: Int = 0
    var actualEndTime = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.amount.delegate = self
    }
  
    @IBAction func confirmBid(_ sender: Any) {
        guard let userPayment = (amount.text as? NSString)?.doubleValue else{
            return
        }
        if userPayment > products[indexPathOfProduct].lowestBid!{
            products[indexPathOfProduct].lowestBid = userPayment
            publish()
            alertWarning(title: "Succes",message: "Your bid was succesfully submitted")
            
        } else {
            alertWarning(title: "Failure!",message: "Your bid must be at least equal with the actual bid")
        }
    }
    
    func alertWarning(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func publish() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let values = ["name" : products[indexPathOfProduct].nameOfProduct,
                      "description" : products[indexPathOfProduct].descriptionOfProduct,
                      "endTime" : products[indexPathOfProduct].endTimeOfProduct,
                      "publishDate" : "\(products[indexPathOfProduct].publishDate!)",
                      "lowestBid" : amount.text] as [String : Any]
        ref.child("users").child(uid!).child(products[indexPathOfProduct].nameOfProduct!).setValue(values)
        
        
        //saving in database
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dismissBidModal" {
            if let destinationVC = segue.destination as? DetailOfProductViewController {
                destinationVC.products = self.products
                destinationVC.users = self.users
                destinationVC.indexPathOfProduct = self.indexPathOfProduct
                destinationVC.actualEndTime = self.actualEndTime
                
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
