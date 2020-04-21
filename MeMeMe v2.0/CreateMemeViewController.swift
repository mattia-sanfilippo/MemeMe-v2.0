//
//  CreateMemeViewController.swift
//  MemeMe v1.0
//
//  Created by Mattia Sanfilippo on 07/04/2020.
//  Copyright © 2020 Mattia Sanfilippo. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    enum PickAnImageButtonType: Int {
        case camera = 0, album
    }
    
    private let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth: -4.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldStyle(topTextField)
        setTextFieldStyle(bottomTextField)
        
        shareButton.isEnabled = false
        
        if(!UIImagePickerController.isSourceTypeAvailable(.camera)){
            cameraButton.isEnabled = false
        }
    }
    
    func setTextFieldStyle(_ textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.tintColor = UIColor.clear
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        switch (PickAnImageButtonType(rawValue: sender.tag)!) {
            case .camera:
                pickAnImageController(.camera)
            case .album:
                pickAnImageController(.photoLibrary)
        }
    }
    
    func pickAnImageController(_ sourceType: UIImagePickerController.SourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView?.contentMode = .scaleAspectFit
        }
        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if (bottomTextField.isEditing){
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
            self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // Create a meme object and save it to the memes array
    func save() {
        
        let generatedMeme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.append(generatedMeme)
        
        dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        hideToolbars(true)

        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideToolbars(false)
        
        let rect: CGRect = imagePickerView.bounds
        let scale = memedImage.scale
        let scaledRect = CGRect(x: imagePickerView.frame.origin.x * scale, y: imagePickerView.frame.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        
        if let cgImage = memedImage.cgImage?.cropping(to: scaledRect) {
            let temp: UIImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
            return temp
        } else {
            return memedImage
        }
    }
    
    func hideToolbars(_ hide: Bool){
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
    }
    
    @IBAction func share(_ sender: Any) {
        
        let memedImage: UIImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
            }
        }
        
        present(controller, animated: true)
        
    }
    @IBAction func cancel(_ sender: Any) {
        topTextField.text = nil
        bottomTextField.text = nil
        imagePickerView.image = nil
        shareButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}

