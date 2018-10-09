//
//  DetailOfProductViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/4/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit

class DetailOfProductViewController: UIViewController {
    @IBOutlet weak var titleOfProduct: UILabel!
    @IBOutlet weak var imageOfProduct: UIImageView!
    @IBOutlet weak var descriptionOfProduct: UITextView!
    @IBOutlet weak var currentBidLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    var products = [Product]()
    var users = [User]()
    var indexPathOfProduct: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.titleOfProduct.text = self.products[self.indexPathOfProduct].nameOfProduct
            self.imageOfProduct.image =  self.products[self.indexPathOfProduct].imageOfProduct
            self.descriptionOfProduct.text = self.products[self.indexPathOfProduct].descriptionOfProduct
            self.currentBidLabel.text = "\(self.products[self.indexPathOfProduct].lowestBid!)$$$"
            self.timeLeftLabel.text = "\(self.products[self.indexPathOfProduct].endTimeOfProduct!)h"
        }
       
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    @IBAction func bidNowAction(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bidModal" {
            if let destinationVC = segue.destination as? BidModalViewController {
                destinationVC.products = self.products
                destinationVC.users = self.users
                destinationVC.indexPathOfProduct = self.indexPathOfProduct
            }
        }
    }
    
}
