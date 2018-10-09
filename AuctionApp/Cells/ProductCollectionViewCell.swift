//
//  ProductCollectionViewCell.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/3/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageOfProduct: UIImageView!
    @IBOutlet weak var descriptionOfProduct: UILabel!
    @IBOutlet weak var priceOfProduct: UILabel!
    @IBOutlet weak var timeLeftOfProduct: UILabel!
    var product: Product?{
        didSet{
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    func setupViews(){
//
//
//
//
//    }
}
