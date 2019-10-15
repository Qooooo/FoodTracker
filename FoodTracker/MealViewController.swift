//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Goh Wei Rong on 15/7/19.
//  Copyright © 2019 Goh Wei Rong. All rights reserved.
//

import UIKit
import os.log
import Photos

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // This value is either passed by `MealTableViewController` in `prepare(for:sender:)` or constructed as part of adding a new meal.
    var meal: Meal?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks
        nameTextField.delegate = self
        
        checkPermission()
    }
    
    func checkPermission()
    {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus
        {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized
                {
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
        @unknown default:
            fatalError("Unknown Photo authorization status.")
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Hide the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        // Disable the Save button while editing
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
//        mealNameLabel.text = textField.text
    }

    // MARK: UIImagePickControllerDelegate
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        // Dismiss the picker if the user cancelled
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else
        {
            fatalError("Expected a dictionary containing an image. but was provided the following \(info)")
        }
        
        // Set photoImageView to display the selected image
        photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else
        {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? "" // ?? returns the value of an optional if the optional has a value, or default value otherwise
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer)
    {
        // Hide the keyboard
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure the ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    // MARK: Private Methods
    private func updateSaveButtonState()
    {
        // Disable the Save button if the text field is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
