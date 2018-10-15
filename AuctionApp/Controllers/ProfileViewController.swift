//
//  ProfileViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/4/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Photos

class ProfileViewController: UIViewController,UITabBarDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    var imagePicker = UIImagePickerController()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.delegate = self
        self.imagePicker.delegate = self
        checkPermission()
        setProfilePictureImageAttributes()
        let name = defaults.string(forKey: "name")
        let email = defaults.string(forKey: "email")
        nameLabel.text = "Name: \(name!)"
        emailLabel.text = "Email: \(email!)"
        
        //read image from possible userDefaults
        if let data = defaults.object(forKey: "savedImage") as? NSData{
            profilePicture.setImage(UIImage(data: data as Data), for: .normal)
        }
    }
    
    func setProfilePictureImageAttributes(){
        profilePicture.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7)
        profilePicture.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7)
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        profilePicture.center = CGPoint(x: w/2, y: h/3)
        profilePicture.layer.cornerRadius = 0.5 * profilePicture.bounds.size.width
        profilePicture.layer.borderWidth = 4.0
        var customGreen = UIColor.init(red: 95/255, green: 232/255, blue: 194/255, alpha: 0.5)
        profilePicture.layer.borderColor = customGreen.cgColor
        profilePicture.translatesAutoresizingMaskIntoConstraints = true
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
    
    @IBAction func addImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profilePicture.imageView?.contentMode = .scaleAspectFill
        profilePicture.setImage(selectedImage, for: .normal)
        //set image in userdefaults
        let imageData:NSData = selectedImage.pngData()! as NSData
        defaults.set(imageData, forKey: "savedImage")
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func alertWarning(title: String,message: String,whichOneToModify: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            switch whichOneToModify{
                case "name": self.defaults.set(textField.text!, forKey: "name")
                case "email": self.defaults.set(textField.text!, forKey: "email")
                default: break
            }
            self.nameLabel.text = "Name: \(self.defaults.string(forKey: "name")!)"
            self.emailLabel.text = "Email: \(self.defaults.string(forKey: "email")!)"
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func modifyName(_ sender: Any) {
        alertWarning(title: "Modify name", message: "", whichOneToModify: "name")
    }
    
    @IBAction func modifyEmail(_ sender: Any) {
        alertWarning(title: "Modify email", message: "", whichOneToModify: "email")
    }
    
}
