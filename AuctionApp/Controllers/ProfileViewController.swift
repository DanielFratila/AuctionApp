//
//  ProfileViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/4/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UITabBarDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "Products":
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "productsViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        case "Add Product":
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "addProductViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        default:
            print("Otherwise, do something else.")
        }
        
    }
    
    @IBAction func modifyName(_ sender: Any) {
        
    }
    
    @IBAction func modifyEmail(_ sender: Any) {
        
    }
    
}
