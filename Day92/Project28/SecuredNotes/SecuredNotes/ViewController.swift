//
//  ViewController.swift
//  SecuredNotes
//
//  Created by Alexander on 9/27/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var secret: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Nothing to see here"
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    
    toggleDoneButtonVisibility()
  }

  func toggleDoneButtonVisibility() {
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(lockApp))
    navigationItem.rightBarButtonItem = (!secret.isHidden) ? doneButton : nil
  }
  
  @objc func lockApp() {
    saveSecretMessage()
  }
  
  @IBAction func authenticateTapped(_ sender: Any) {
    let context = LAContext()
    var error: NSError?
    
    // Used for devices with fingerprint reader ONLY
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      let reason = "Identify yourself!"
      
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
        DispatchQueue.main.async {
          if success {
            self?.unlockSecretMessage()
          } else {
            // user failed to authenticate
            let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
          }
        }
      }
    } else {
      // no biometry
      let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      present(ac, animated: true)
      
    }
  }
 
  @objc func adjustForKeyboard(notification: Notification) {
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    // Size of the keyboard relative to the screen, not the view. Doesn't account for rotation.
    let keyboardScreenEnd = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
    
    if notification.name == UIResponder.keyboardWillHideNotification {
      secret.contentInset = .zero
    } else {
      secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
      let selectedRange = secret.selectedRange
      secret.scrollRangeToVisible(selectedRange)
    }
  }
  
  func unlockSecretMessage() {
    secret.isHidden = false
    toggleDoneButtonVisibility()
    title = "Secret stuff!"
    secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
  }
  
  @objc func saveSecretMessage() {
    guard secret.isHidden == false else { return }
    
    KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
    secret.resignFirstResponder()
    secret.isHidden = true
    toggleDoneButtonVisibility()
    title = "Nothing to see here"
  }
}

