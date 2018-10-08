//
//  AddProductViewController.swift
//  AuctionApp
//
//  Created by Daniel Fratila on 10/4/18.
//  Copyright © 2018 Daniel Fratila. All rights reserved.
//

import UIKit
import Firebase
import Photos
import FirebaseStorage
import FirebaseDatabase

class AddProductViewController: UIViewController, UITabBarDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate {

   
    @IBOutlet weak var imageOfProduct: UIButton!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var lowestBidField: UITextField!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextField.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextField.layer.borderWidth = 1.0
        self.tabBar.delegate = self
        self.nameField.delegate = self
        self.endTimeField.delegate = self
        self.lowestBidField.delegate = self
        self.imagePicker.delegate = self
        checkPermission()
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    @IBAction func addImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        imageOfProduct.imageView?.contentMode = .scaleAspectFit
        imageOfProduct.setImage(selectedImage, for: .normal)
        
        
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
            
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
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
    @IBAction func publish(_ sender: Any) {
        guard let image = imageOfProduct.currentImage,let name = nameField.text,
            let description = descriptionTextField.text, let endTime = endTimeField.text, let lowestBid = lowestBidField.text else{
            print("Form is not valid")
            return
        }
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let values = ["name" : name,
                      "description" : description,
                      "endTime" : endTime,
                      "lowestBid" : lowestBid] as [String : Any]
        ref.child("users").child(uid!).child(name).setValue(values)
        saveImageInStorage(images: image, uids: uid!,name: name)
        
        
        //saving in storage
        

    }
    
    func saveImageInStorage(images: UIImage, uids: String, name: String){
        let storageRef = Storage.storage().reference().child(uids).child("productImage").child(name)
        if let uploadData = images.pngData()
        { storageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
                
            })
        }
    }
}
