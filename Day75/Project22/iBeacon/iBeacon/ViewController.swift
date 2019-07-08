//
//  ViewController.swift
//  iBeacon
//
//  Created by Alexander on 7/7/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var distanceReading: UILabel!
  var locationManager: CLLocationManager?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestAlwaysAuthorization()
    
    view.backgroundColor = .gray
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways {
      if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        if CLLocationManager.isRangingAvailable() {
          startScanning()
        }
      }
    }
  }
  
  func startScanning() {
    let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")! // apple provided test uuid string
    let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
    
    locationManager?.startMonitoring(for: beaconRegion)
    locationManager?.startRangingBeacons(in: beaconRegion)
  }
  
  func update(distance: CLProximity) {
    UIView.animate(withDuration: 1) {
      switch distance {
      case .far:
        self.view.backgroundColor = .blue
        self.distanceReading.text = "FAR"
        
      case .near:
        self.view.backgroundColor = .orange
        self.distanceReading.text = "NEAR"
        
      case .immediate:
        self.view.backgroundColor = .red
        self.distanceReading.text = "RIGHT HERE"
        
      default:
        self.view.backgroundColor = .gray
        self.distanceReading.text = "UNKNOWN"
      }
    }
  }
  
  // Called when beacon first encountered. Note the beacon must be off when the app launches to be detected as entered region.
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    showBeaconAlert(message: "Did enter region with identifier: \(region.identifier)")
  }
  
  // Called when no beacon signal has been present for over 30 seconds
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    showBeaconAlert(message: "Did leave region with identifier: \(region.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    showBeaconAlert(message: "Location Error: \(error)")
  }
  
  // Called when beacon is detected
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    if let beacon = beacons.first {
      update(distance: beacon.proximity)
    } else {
      update(distance: .unknown)
    }
  }
  
  func showBeaconAlert(message: String) {
    let ac = UIAlertController(title: "Beacon Alert", message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(ac, animated: true)
  }
  
}

