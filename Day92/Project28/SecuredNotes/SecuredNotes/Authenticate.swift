//
//  Authenticate.swift
//  SecuredNotes
//
//  Created by Alexander on 10/5/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

enum PasswordError: String, Error {
  case empty = "Password cannot by empty."
  case wrong = "Password is incorrect.\nPlease verify and try again."
  case tooShort = "Password has to be no less than 6 characters."
  case doesntMatchVerify = "Password and Verify Password do not match."
  case unknownError = "Unknown password error."
}

class Authenticate {
  
  static weak var controller: ViewController?
  
  static func inititialize(host: ViewController) {
    controller = host
  }
  
  static func withBiometrics(context: LAContext) {
    let reason = "Identify yourself to access secured note!"
    
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak controller] success, authenticationError in
      DispatchQueue.main.async {
        if success {
          controller?.unlockSecretMessage()
        } else {
          
          guard let error = authenticationError as? LAError else { print("Unable to cast Error as LAError."); return }
          
          var message = ""
          switch error.code {
          case .userCancel:
            message = "Authentication is required to view the note."
          case .userFallback:
            withPassword()
            return
          default:
            message = "Error code: \(error.code)"
          }
          
          // user failed to authenticate
          let ac = UIAlertController(title: "Authentication Error!", message: message, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          controller?.present(ac, animated: true)
        }
      }
    }
  }
  
  static func withPassword() {
    //1. Check to see if password exists
    let password = KeychainWrapper.standard.string(forKey: "securedNotesKey") ?? ""
    
    //2. If password exists, verify password
    if !password.isEmpty {
      checkPassword(savedPassword: password)
    }
    //3. If it doesn't, prompt for password creation
    else {
      createPassword()
    }
  }
  
  static func createPassword() {
    guard let controller = controller else { print("ViewController is not available. File: \(#file). Line # \(#line)"); return }
    
    let ac = UIAlertController(title: "Create Password", message: "", preferredStyle: .alert)
    ac.addTextField { textField in
      textField.placeholder = "Password"
      textField.isSecureTextEntry = true
      textField.minimumFontSize = 14
    }
    ac.addTextField { textField in
      textField.placeholder = "Verify Password"
      textField.isSecureTextEntry = true
      textField.minimumFontSize = 14
    }
    ac.addAction(UIAlertAction(title: "Create", style: .default) { [weak ac] _ in
      guard let password = ac?.textFields?[0].text       else { print("Unable to locate password field. File: \(#file). Line #: \(#line)"); return }
      guard let verifyPassword = ac?.textFields?[1].text else { print("Unable to locate verify password field. File: \(#file). Line # \(#line)"); return }
    
      if password.isEmpty {
        showError(type: .empty) { createPassword() }
      }
      if password.count < 6 {
        showError(type: .tooShort) { createPassword() }
      } else if password != verifyPassword {
        showError(type: .doesntMatchVerify){ createPassword() }
      } else if password == verifyPassword {
        KeychainWrapper.standard.set(password, forKey: "securedNotesKey")
        controller.unlockSecretMessage()
        return
      } else {
        showError(type: .unknownError) {}
      }
    })
    controller.present(ac, animated: true)
    
  }
  
  static func checkPassword(savedPassword: String) {
    guard let controller = controller else { print("ViewController is not available. File: \(#file). Line # \(#line)"); return }
    
    let ac = UIAlertController(title: "Please Enter Password to Login", message: "", preferredStyle: .alert)
    ac.addTextField { textField in
      textField.placeholder = "Password"
      textField.isSecureTextEntry = true
      textField.minimumFontSize = 14
    }
    ac.addAction(UIAlertAction(title: "Verify", style: .default) { [weak ac] _ in
      guard let password = ac?.textFields?[0].text       else { print("Unable to locate password field. File: \(#file). Line #: \(#line)"); return }
  
      if password == savedPassword {
        controller.unlockSecretMessage()
      } else {
        showError(type: .wrong){ withPassword() }
      }
      
    })
    controller.present(ac, animated: true)
  }
  
  static func showError(type error: PasswordError, _ callback: (() -> Void)?) {
    guard let controller = controller else { print("ViewController is not available. File: \(#file). Line # \(#line)"); return }
    
    let ac = UIAlertController(title: "Error!", message: error.rawValue, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
      guard let callback = callback else { return }
      callback()
    })
    controller.present(ac, animated: true)
  }
}
