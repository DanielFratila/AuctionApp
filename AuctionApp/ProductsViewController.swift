//
//  ProductsViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/3/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Firebase

class ProductsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UITabBarDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tabBar: UITabBar!
    var users = [User]()
    var products = [Product]()
    //var aux = Product(imageOfProduct: UIImage(named: "jeepIcon")!, nameOfProduct: "Jeep", priceOfProduct: 22.500, offerExpires: 10)
    
    @IBOutlet weak var searchTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.init(red: 160.0/255.0, green: 160.0/255.0, blue: 160.0/255.0, alpha: 0.5)
        collectionView.alwaysBounceVertical = true
        self.tabBar.delegate = self
        fetchDataFromFirebase()
    }
    
    override var prefersStatusBarHidden: Bool { return true }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-16, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productDetail", for: indexPath) as? ProductCollectionViewCell
        //cell?.product = aux
        cell?.backgroundColor = UIColor.white
        cell!.imageOfProduct.image = UIImage(named: "jeepIcon")
        cell?.descriptionOfProduct.text = "Jeep"
        cell?.priceOfProduct.text = "US $ 22.999"
        cell?.timeLeftOfProduct.text = "Time left 04:39:02"
        return cell!
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "Add Product":
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "addProductViewController")
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
    
//    func fetchData(){
//        let ref = Database.database().reference()
//        ref.observeSingleEvent(of: .value) { snapshot in
//            print(snapshot.childrenCount) // I got the expected number of items
//            let enumerator = snapshot.children
//            while let rest = enumerator.nextObject() as? DataSnapshot {
//                print(rest.value)
//
//
//                }
//            }
//}
    func fetchDataFromFirebase() {
        let refUsers = Database.database().reference().child("users");
        
        //observing the data changes
        refUsers.observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                
                //clearing the list
                self.users.removeAll()
                self.products.removeAll()
                //iterating through all the values
                for aux in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    
                    let userObject = aux.value as? [String: AnyObject]
                    let id = aux.key
                    let email  = userObject?["email"] as? String
                    //for productDetail in aux.children.allObjects {
                    var product: Product
                    if let productDescription = userObject!["description"]  as? String{
                        product = Product()
                        product.descriptionOfProduct = productDescription as? String
                        if let endTime = userObject!["endTime"] {
                            product.endTimeOfProduct = endTime as? String
                            if let lowestBid = userObject!["lowestBid"] {
                                product.lowestBid = lowestBid as? Double
                                if let name = userObject!["name"] {
                                    product.nameOfProduct = name as? String
                                }
                            }
                        }
                         self.products.append(product)
                    }

                    
                   
                    
                    
                    

                   
                    //}
                    let user = User()
                    user.email = email
                    user.id = id
                    user.products = self.products
                    
                    self.users.append(user)
                    
                    
                    //appending it to list if user == the one the has been searched
//                    if (user.username.lowercased()).hasPrefix(s.lowercased()) {
//                        self.users.append(user)
//                    }
                }
                
                //reloading the tableview
                self.collectionView.reloadData()
            }
        })
    }




    }
    //
    //            if let email = snapshot.childSnapshot(forPath: "email").value{
    //            var user = User()
    //            user.email = email as! String
    //            user.id = Auth.auth().currentUser?.uid
    //            self.users.append(user)


//        Database.database().reference().child("users").observeSingleEvent(of: .value, with : { (snapshot) in
//            //print(snapshot)
//            if let dictionary = snapshot.value as? [String: String]{
//                let user = User()
//                user.email = dictionary["email"]
//                user.id = Auth.auth().currentUser?.uid
//                self.users.append(user)
//                self.collectionView.reloadData()
//
//                }
//            })
