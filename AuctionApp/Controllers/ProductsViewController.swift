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
    var activityindicator = UIActivityIndicatorView()
    var destinationGlobalController = DetailOfProductViewController()
    //var aux = Product(imageOfProduct: UIImage(named: "jeepIcon")!, nameOfProduct: "Jeep", priceOfProduct: 22.500, offerExpires: 10)
    
    @IBOutlet weak var searchTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.init(red: 160.0/255.0, green: 160.0/255.0, blue: 160.0/255.0, alpha: 0.5)
        collectionView.alwaysBounceVertical = true
        self.tabBar.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        fetchDataFromFirebase()
    }
    override var prefersStatusBarHidden: Bool { return true }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-16, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        destinationGlobalController.indexPathOfProduct = indexPath.item
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productDetail", for: indexPath) as? ProductCollectionViewCell
        //cell?.product = aux
        
        cell?.backgroundColor = UIColor.white
        if let aux = products[indexPath.item].imageOfProduct{
            cell!.imageOfProduct.image = aux
        }
        if let aux = products[indexPath.item].nameOfProduct{
            cell?.descriptionOfProduct.text = aux
        }
        if let aux = products[indexPath.item].lowestBid {
            cell?.priceOfProduct.text = "\(aux) $$$"
        }
        if let aux = products[indexPath.item].endTimeOfProduct{
            cell?.timeLeftOfProduct.text = aux + "h"
        }
        
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
                    for (key,value) in userObject!{
                        //print("key \(key) with value \(value)")
                        let product = Product()
                        if !key.elementsEqual("email"){
                            let detailsOfProduct = value as? [String: String]                            
                            product.descriptionOfProduct = detailsOfProduct!["description"]
                            product.endTimeOfProduct = detailsOfProduct!["endTime"]
                            product.lowestBid = (detailsOfProduct!["lowestBid"] as! NSString).doubleValue
                            product.nameOfProduct = detailsOfProduct!["name"]
                            
                            var image = UIImage()
                            image = self.putCurrentProductpPhoto(idOfUser: id,name: product.nameOfProduct!,product: product)
                            product.imageOfProduct = image
                        }
                        //if product was modified and exists we re appending to products
                        if let aux = product.descriptionOfProduct{
                            
                            self.products.append(product)
                        }
                    }
                    let user = User()
                    user.email = email
                    user.id = id
                    user.products = self.products
                    
                    self.users.append(user)
                   
                }
                
                
            }
        })
        startActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // change 2 to desired number of seconds
            print("prooodutcs before reloading \(self.products.count)")
            print("users \(self.users.count)")
            self.stopActivityIndicator()
            self.collectionView.reloadData()
        }
        
    }
    func startActivityIndicator(){
        activityindicator.center = self.view.center
        activityindicator.hidesWhenStopped = true
        activityindicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityindicator)
        
        activityindicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    func stopActivityIndicator(){
        activityindicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    func putCurrentProductpPhoto(idOfUser: String,name: String, product: Product) -> UIImage {
        let storageRef = Storage.storage().reference().child(idOfUser).child("productImage").child(name)
        var image = UIImage()
        var bool: Bool = false
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for “images/island.jpg” is returned
                image = UIImage(data: data!)!
                bool = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if bool == true{
                product.imageOfProduct = image
                print(bool)
            }
        }
        
        return UIImage(named: "noImageIcon")!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let destinationVC = segue.destination as? DetailOfProductViewController {
                destinationVC.products = self.products
                destinationVC.users = self.users
                destinationGlobalController = destinationVC
                }
            }
    }
}
//appending it to list if user == the one the has been searched
//                    if (user.username.lowercased()).hasPrefix(s.lowercased()) {
//                        self.users.append(user)
//                    }
//reloading the tableview
//
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



//                    if let productDescription = userObject!["description"]  as? String{
//                        product = Product()
//                        product.descriptionOfProduct = productDescription as? String
//                        if let endTime = userObject!["endTime"] {
//                            product.endTimeOfProduct = endTime as? String
//                            if let lowestBid = userObject!["lowestBid"] {
//                                product.lowestBid = lowestBid as? Double
//                                if let name = userObject!["name"] {
//                                    product.nameOfProduct = name as? String
//                                }
//                            }
//                        }
//                         self.products.append(product)
//                    }

