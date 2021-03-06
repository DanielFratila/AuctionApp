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

class AddProductViewController: UIViewController, UITabBarDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate  {
   
    @IBOutlet weak var imageOfProduct: UIButton!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var lowestBidField: UITextField!
    @IBOutlet weak var containterViewOfFields: UIView!
    var imagePicker = UIImagePickerController()
    let timePicker = UIDatePicker()
    var animateDistance: CGFloat!

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
        textField.resignFirstResponder()
        return true
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    @IBAction func tapOutsideViewDismiss(_ sender: Any) {
        self.view.endEditing(true)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == endTimeField{
            self.view.endEditing(true)
            openTimePicker()
            return

        }
        let textFieldRect : CGRect = self.view.window!.convert(textField.bounds, from: textField)
        let viewRect : CGRect = self.view.window!.convert(self.view.bounds, from: self.view)
        
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        
        let orientation : UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if (orientation == UIInterfaceOrientation.portrait || orientation == UIInterfaceOrientation.portraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == endTimeField {
            return
        }
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
        
    }
//        let xPosition = containterViewOfFields.frame.origin.x
//
//        //View will slide 20px up
//        let yPosition = containterViewOfFields.frame.origin.y - 150
//
//        let height = containterViewOfFields.frame.size.height
//        let width = containterViewOfFields.frame.size.width
//
//        //        UIView.animate(withDuration: 0.1, animations: {
//
//        //self.containterViewOfFields.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
//        for constraint in self.containterViewOfFields.constraints {
//            if constraint.identifier == "modifiedTopSpace" {
//                constraint.constant = 50
//            }
//        }
//        containterViewOfFields.layoutIfNeeded()
//
//    }
//    @objc func keyboardWillShow(sender: NSNotification) {
//        self.containterViewOfFields.frame.origin.y = -150 // Move view 150 points upward
//    }
//
//    @objc func keyboardWillHide(sender: NSNotification) {
//        self.containterViewOfFields.frame.origin.y = 0 // Move view to original position
//    }
    
    func openTimePicker() {
        timePicker.datePickerMode = UIDatePicker.Mode.time
        timePicker.frame = CGRect(x: 0.0, y: (self.view.frame.height/2 + 60), width: self.view.frame.width, height: 150.0)
        timePicker.backgroundColor = UIColor.white
        self.view.addSubview(timePicker)
        timePicker.addTarget(self, action: #selector(self.startTimeDiveChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        endTimeField.text = formatter.string(from: sender.date)
        timePicker.removeFromSuperview() // if you want to remove time picker
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
            alertWarning(title: "Failure", message: "Form is not valid!You must complete all fields and add a photo")
            return
        }
        if image.images?.count == 0 || name == "" || description == "" || endTime == "" || lowestBid == "" {
            alertWarning(title: "Failure", message: "Form is not valid!You must complete all fields and add a photo")
            return
        }
        let imageSize = getImageSizeInBytes(image: image)
        if imageSize/1000 > 1047{
            alertWarning(title: "Failure", message: "Your image exceeds 1048 kB.Please upload another one!")
            return
        }
        guard let lowestBidInteger = Int(lowestBid) else {
            alertWarning(title: "Failure", message: "You must put a number which represents amount of dollars")
            return
        }
//        var verifyEndTime = verifyEndTimeFormat(time: endTime)
//        if !verifyEndTime {
//            alertWarning(title: "Failure", message: "Your end time format is not corect")
//            return
//        }
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let values = ["name" : name,
                      "description" : description,
                      "endTime" : endTime.substring(to:endTime.index(endTime.startIndex, offsetBy: 8)),
                      "publishDate" : String(NSDate().timeIntervalSince1970),
                      "lowestBid" : lowestBid] as [String : Any]
        ref.child("users").child(uid!).child(name).setValue(values)
        saveImageInStorage(images: image, uids: uid!,name: name)
        alertWarning(title: "Success", message: "Your product has been registered")
    }
    
    func getImageSizeInBytes(image: UIImage) -> Int{
        let imgData = image.pngData()
        print("Size of Image: \(imgData?.count) bytes")
        return (imgData?.count)!
        
    }
//    func verifyEndTimeFormat(time: String) -> Bool{
//        var components: Array = time.components(separatedBy: ":")
//        guard let hours = Int(components[0]), let minutes = Int(components[1]), let seconds = Int(components[2]) else {
//            return false
//        }
//        //if (hours >= 0 && hours <= 99) && (minutes >= 0 && minutes <= 99) && (seconds >= 0 && seconds <= 99)
//        return true
//    }
    func saveImageInStorage(images: UIImage, uids: String, name: String){
        let storageRef = Storage.storage().reference().child(uids).child("productImage").child(name)
        if let uploadData = images.pngData()
        { storageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
            guard let metadata = metadata else {
                self.alertWarning(title: "Failure",message: "Your image exceeds 1048 kB")
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
    
    func alertWarning(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
