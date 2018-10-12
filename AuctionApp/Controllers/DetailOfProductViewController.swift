//
//  DetailOfProductViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/4/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit

class DetailOfProductViewController: UIViewController , UITabBarDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var titleOfProduct: UILabel!
    @IBOutlet weak var imageOfProduct: UIImageView!
    @IBOutlet weak var descriptionOfProduct: UITextView!
    @IBOutlet weak var currentBidLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    
    var products = [Product]()
    var users = [User]()
    var indexPathOfProduct: Int = 0
    var actualEndTime = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.titleOfProduct.text = self.products[self.indexPathOfProduct].nameOfProduct
            self.imageOfProduct.image =  self.products[self.indexPathOfProduct].imageOfProduct
            self.descriptionOfProduct.text = self.products[self.indexPathOfProduct].descriptionOfProduct
            self.currentBidLabel.text = "Current bid: \(self.products[self.indexPathOfProduct].lowestBid!)$"
            self.timeLeftLabel.text = "Time left: \(self.actualEndTime)h"
            self.tabBar.delegate = self
        
       
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "Add Product":
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "addProductViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        case "Products":
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "productsViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        case "Profile":
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "profileViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        default:
            print("Otherwise, do something else.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bidModal" {
            if let destinationVC = segue.destination as? BidModalViewController {
                destinationVC.products = self.products
                destinationVC.users = self.users
                destinationVC.indexPathOfProduct = self.indexPathOfProduct
                destinationVC.actualEndTime = self.actualEndTime
            }
        }
    }
    
}
