//
//  ViewController.swift
//  MapKit_Project1
//
//  Created by Alexander on 5/18/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var mapType: UIButton!
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapType.layer.cornerRadius = 5
    mapType.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
    
    let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home of the 2012 Summer Olympics.")
    let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "FOunded over a thousand years ago.")
    let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
    let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
    let washington = Capital(title: "Washington", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.836667), info: "Named after George himself.")
    
    mapView.addAnnotations([london, oslo, paris, rome, washington])
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is Capital else { return nil }
    
    let identifier = "Capital"
    
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
    
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      annotationView?.canShowCallout = true
      
      let btn = UIButton(type: .detailDisclosure)
      annotationView?.rightCalloutAccessoryView = btn
    } else {
      annotationView?.annotation = annotation
    }
    
    // 1
    annotationView?.pinTintColor = .purple
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    guard let capital = view.annotation as? Capital else { return }
    
    let placeName = capital.title
    
    // 3
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "WikiInfoController") as? DetailsViewController else { return }
    vc.city = placeName
    
    navigationController?.pushViewController(vc, animated: true)
  }
  
  // 2
  @IBAction func mapTypeHandler(_ sender: UIButton) {
    let ac = UIAlertController(title: "Select Map View Type", message: nil, preferredStyle: .actionSheet)
    
    ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: { [weak mapView] (alert) in mapView?.mapType = .standard; sender.setTitle(alert.title, for: .normal) }))
    ac.addAction(UIAlertAction(title: "Standard Muted", style: .default, handler: { [weak mapView] (alert) in mapView?.mapType = .mutedStandard; sender.setTitle(alert.title, for: .normal) }))
    ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { [weak mapView] (alert) in mapView?.mapType = .hybrid; sender.setTitle(alert.title, for: .normal) }))
    ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: { [weak mapView] (alert) in mapView?.mapType = .hybridFlyover; sender.setTitle(alert.title, for: .normal) }))
    ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { [weak mapView] (alert) in mapView?.mapType = .satellite; sender.setTitle(alert.title, for: .normal) }))
    ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: { [weak mapView] (alert) in mapView?.mapType = .satelliteFlyover; sender.setTitle(alert.title, for: .normal) }))
    
    present(ac, animated: true)
  }
  
}

