//
//  Product.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/3/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import Foundation
import UIKit

class Product: NSObject{
    
    var imageOfProduct: UIImage?
    var nameOfProduct: String?
    var priceOfProduct: Double?
    var offerExpires: String?
    var descriptionOfProduct: String?
    var endTimeOfProduct: String?
    var lowestBid: Double?
    var currentBid: Double?
    var publishDate: Double?
}
