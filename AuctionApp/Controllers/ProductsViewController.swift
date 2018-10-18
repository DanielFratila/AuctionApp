//
//  ProductsViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/3/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Firebase

class ProductsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UITabBarDelegate ,UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    
    
    @IBOutlet weak var searchingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tabBar: UITabBar!
    var users = [User]()
    var products = [Product]()
    var activityindicator = UIActivityIndicatorView()
    var filtered: [Product] = []
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    var timer = [Timer]()
    var isTimerRunning = false
    var secondsOfOfferedProduct = [Int]()
    var offerLabels = [UILabel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        fetchDataFromFirebase()
        
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    func setDelegates() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.init(red: 160.0/255.0, green: 160.0/255.0, blue: 160.0/255.0, alpha: 0.5)
        collectionView.alwaysBounceVertical = true
        self.tabBar.delegate = self
        //setting searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for products name"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        
        searchingView.addSubview(searchController.searchBar)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        else
        {
            return products.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-16, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        invalidateTimerForOffer()
        let destinationGlobalController = self.storyboard!.instantiateViewController(withIdentifier: "DetailOfProductViewController") as! DetailOfProductViewController
        destinationGlobalController.indexPathOfProduct = indexPath.item
        destinationGlobalController.products = self.filtered
        destinationGlobalController.users = self.users
        destinationGlobalController.actualEndTime = "\(timeStringFromSecondsToHHMMSS(time: TimeInterval(secondsOfOfferedProduct[indexPath.item])))"  //modify endTime of selected product to actual
        searchController.searchBar.resignFirstResponder()
        searchActive = false
        self.show(destinationGlobalController, sender: self)
//        self.present(destinationGlobalController, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productDetail", for: indexPath) as? ProductCollectionViewCell
        
        cell?.backgroundColor = UIColor.white
        if let aux = filtered[indexPath.item].imageOfProduct{
            cell!.imageOfProduct.image = aux
        }
        if let aux = filtered[indexPath.item].nameOfProduct{
            cell?.descriptionOfProduct.text = aux
        }
        if let aux = filtered[indexPath.item].lowestBid {
            cell?.priceOfProduct.text = "\(aux) $$$"
        }
        if let aux = filtered[indexPath.item].endTimeOfProduct{
            var auxTimer = Timer()
            timer.append(auxTimer)
            secondsOfOfferedProduct.append(0)
            offerLabels.append((cell?.timeLeftOfProduct)!)
            runTimer(index: indexPath.item)
        }
        
        return cell!
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "Add Product":
            invalidateTimerForOffer()
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "addProductViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        case "Profile":
            invalidateTimerForOffer()
            let viewContr = self.storyboard?.instantiateViewController(withIdentifier: "profileViewController")
            viewContr!.modalTransitionStyle = .crossDissolve
            self.present(viewContr!, animated: true, completion: nil)
        default:
            print("Otherwise, do something else.")
        }
        
    }
    
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
                            product.publishDate = (detailsOfProduct!["publishDate"]  as! NSString).doubleValue
                            
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
            if self.searchController.searchBar.text == ""{
                self.filtered = self.products
            }
            self.collectionView.reloadData()
        }
        
    }
    
    func runTimer(index: Int) {
        
        timer[index] = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer(sender:))), userInfo: ["index": index], repeats: true)
        
    }
    
    @objc func updateTimer(sender: Timer) {
        
        var userInfoMap = sender.userInfo! as! [String: Any]
        var index = userInfoMap["index"] as! Int
        secondsOfOfferedProduct[index] = (Int(products[index].publishDate!) + timeStringFromHHMMSSToSeconds(string: products[index].endTimeOfProduct!)) -
            Int(NSDate().timeIntervalSince1970)
        if (secondsOfOfferedProduct[index] < 0){
            secondsOfOfferedProduct[index] = 0
            timer[index].invalidate()
        }else {
             secondsOfOfferedProduct[index] -= 1
            
        }
        offerLabels[index].text = "\(timeStringFromSecondsToHHMMSS(time: TimeInterval(secondsOfOfferedProduct[index])))"
    }
    
    func invalidateTimerForOffer(){
        for aux in timer{
            aux.invalidate()
        }
    }
//    secondsOfOfferedProduct[index] = (Int(products[index].publishDate!) + timeStringFromHHMMSSToSeconds(string: products[index].endTimeOfProduct!)) -
//    Int(products[index].publishDate!) + Int(NSDate().timeIntervalSince1970)
//    secondsOfOfferedProduct[index] -= 2
//    let dateOffer = NSDate(timeIntervalSince1970: TimeInterval(secondsOfOfferedProduct[index]))
//    offerLabels[index].text = "\(dateOffer)"
//    products[index].endTimeOfProduct = timeStringFromSecondsToHHMMSS(time: TimeInterval(secondsOfOfferedProduct[index]))
    
    func timeStringFromHHMMSSToSeconds (string: String) -> Int {
        var components: Array = string.components(separatedBy: ":")
        if let hours = Int(components[0]){
            if let minutes = Int(components[1]){
                if let seconds = Int(components[2]){
                    return hours * 60 * 60 + minutes * 60 + seconds
                }
                return hours * 60 * 60 + minutes * 60
            }
            return hours * 60 * 60
        }
        return 0
        
    }
    
    func timeStringFromSecondsToHHMMSS(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
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
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        filtered = products
        //collectionView.reloadData()
        //self.dismiss(animated: true, completion: nil)
    }
    func updateSearchResults(for searchController: UISearchController) {
        var searchProducts = [Product]()
        let searchString = searchController.searchBar.text
        if searchString != "" {
        for auxiliarProduct in products{
            if auxiliarProduct.nameOfProduct!.lowercased().contains(searchString!.lowercased()){
                searchProducts.append(auxiliarProduct)
            }
        }
        filtered = searchProducts
        
        self.collectionView.reloadData()
        } else {
            filtered = products
            collectionView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        filtered = products
        collectionView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        filtered = products
        collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        filtered = products
        if !searchActive {
            searchActive = true
            collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }

}
