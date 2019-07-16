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
  @IBOutlet weak var closestBeaconLabel: UILabel!
  var locationManager: CLLocationManager?
  var closestBeacon: CLBeacon!
  var regionOfClosestBeacon: CLRegion! {
    didSet {
      self.closestBeaconLabel.text = self.regionOfClosestBeacon.identifier
    }
  }
  var activeBeacons = [CLBeacon]()
  
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
    let uuids = [
      UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!: "Apple Test",      // Apple provided test uuid string
      UUID(uuidString: "5AFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!: "RedBear Labs",    // RedBear Labs AFFFFFF
      UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!: "Radius Networks"  // Radius Networks 2F234454
    ]
    
    // Remove inactive regions
    if let regions = locationManager?.monitoredRegions {
      for region in regions {
        locationManager?.stopMonitoring(for: region)
      }
    }
    
    for uuid in uuids {
      let beaconRegion = CLBeaconRegion(proximityUUID: uuid.key, major: 0, minor: 0, identifier: uuid.value)
      locationManager?.startMonitoring(for: beaconRegion)
      locationManager?.startRangingBeacons(in: beaconRegion)
    }
  }
  
  func update(region: CLRegion, beacon: CLBeacon) {
    
    closestBeacon = beacon
    regionOfClosestBeacon = region
    
    UIView.animate(withDuration: 1) {
      switch self.closestBeacon.proximity {
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
    for beacon in beacons {
      // Update activeBeacons array
      if !activeBeacons.contains(where: {
        $0.proximityUUID == beacon.proximityUUID &&
        $0.major == beacon.major &&
        $0.minor == beacon.minor
      }) {
        activeBeacons.append(beacon)
      }
      else {
        let index = activeBeacons.firstIndex(where: {
          $0.proximityUUID == beacon.proximityUUID &&
          $0.major == beacon.major &&
          beacon.minor == beacon.minor
        })!
        activeBeacons[index] = beacon

        // Sort activeBeacons array by proximity from closest to furthers
        // based on proximity.rawValue, smaller => closer to reciever
        activeBeacons.sort { $0.proximity.rawValue < $1.proximity.rawValue }
        // Remove Beacons with "".unknown proximity (rawValue = 0)
        activeBeacons.removeAll(where: {$0.proximity == .unknown})
      }
      
      // Update lavels to closest beacon
      if !activeBeacons.isEmpty {
        let regions = locationManager?.monitoredRegions.filter({ let region = $0 as? CLBeaconRegion; return region != nil}) as? Set<CLBeaconRegion>
        update(region: regions?.first(where: {$0.proximityUUID == activeBeacons[0].proximityUUID}) ?? region, beacon: activeBeacons[0])
      }
    }
  }
  
  func showBeaconAlert(message: String) {
    let ac = UIAlertController(title: "Beacon Alert", message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(ac, animated: true)
  }
  
}

