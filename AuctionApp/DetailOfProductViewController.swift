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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
     override var prefersStatusBarHidden: Bool { return true }
    
    @IBAction func bidNowAction(_ sender: Any) {
        
    }
    
    
}
