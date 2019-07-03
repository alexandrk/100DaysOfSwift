//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Alexander on 7/1/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
  }

  @objc func registerLocal() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print("Yay!")
      } else {
        print("Nay!")
      }
    }
  }
  
  @objc func scheduleLocal() {
    registerCategories()
    
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    
    let content = UNMutableNotificationContent()
    content.title = "Late wake up call"
    content.body = "The early bird catches the worm, but the second mouse gets the cheese."
    content.categoryIdentifier = "alarm"
    content.userInfo = ["customData": "fizzbuzz"]
    content.sound = .default
    
    var dateComponents = DateComponents()
    dateComponents.hour = 10
    dateComponents.minute = 30
    
    //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
  
    center.add(request)
  }
  
  func registerCategories() {
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    
    let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
    let postpond = UNNotificationAction(identifier: "reschedule", title: "Remind me in 24 hours", options: .destructive)
    let category = UNNotificationCategory(identifier: "alarm", actions: [show, postpond], intentIdentifiers: [])
    
    center.setNotificationCategories([category])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // pull out the buried userInfo dictionary
    let userInfo = response.notification.request.content.userInfo
    let alertTitle = "TYPE OF ALERT USER ACTION"
    var alertMessage = ""
    
    if let customData = userInfo["customData"] as? String {
      print("Custom data received: \(customData)")
      
      switch response.actionIdentifier {
      case UNNotificationDefaultActionIdentifier:
        // the user swiped to unlock
        alertMessage = "Default identifier"
        
      case "show":
        alertMessage = "Show more information..."
        
      case "reschedule":
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1*60*60*24, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: response.notification.request.content, trigger: trigger)
        center.add(request)
      
      default:
        break
      }
    }
    
    if response.actionIdentifier != "reschedule" {
      let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .cancel))
      present(ac, animated: true)
    }
    
    // you must call the completion handler when you're done
    completionHandler()
  }
  
}

