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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.delegate = self
        self.imagePicker.delegate = self
        checkPermission()
        setProfilePictureImageAttributes()
        
    }
    
    func setProfilePictureImageAttributes(){
        profilePicture.layer.cornerRadius = 0.5 * profilePicture.bounds.size.width
        profilePicture.layer.borderWidth = 5.0
        var customGreen = UIColor(red: 95, green: 232, blue: 194, alpha: 0.5)
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
    
    @IBAction func modifyName(_ sender: Any) {
        
    }
    
    @IBAction func modifyEmail(_ sender: Any) {
        
    }
    
}
