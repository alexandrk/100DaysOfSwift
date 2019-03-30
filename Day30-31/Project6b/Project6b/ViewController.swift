//
//  ViewController.swift
//  Project6b
//
//  Created by Alexander Kazakov on 3/29/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label1 = UILabel()
    label1.translatesAutoresizingMaskIntoConstraints = false
    label1.backgroundColor = .red
    label1.text = "THESE"
    label1.sizeToFit()
    
    let label2 = UILabel()
    label2.translatesAutoresizingMaskIntoConstraints = false
    label2.backgroundColor = .cyan
    label2.text = "ARE"
    label2.sizeToFit()
    
    let label3 = UILabel()
    label3.translatesAutoresizingMaskIntoConstraints = false
    label3.backgroundColor = .yellow
    label3.text = "SOME"
    label3.sizeToFit()
    
    let label4 = UILabel()
    label4.translatesAutoresizingMaskIntoConstraints = false
    label4.backgroundColor = .green
    label4.text = "AWESOME"
    label4.sizeToFit()
    
    let label5 = UILabel()
    label5.translatesAutoresizingMaskIntoConstraints = false
    label5.backgroundColor = .orange
    label5.text = "LABELS"
    label5.sizeToFit()
    
    
    view.addSubview(label1)
    view.addSubview(label2)
    view.addSubview(label3)
    view.addSubview(label4)
    view.addSubview(label5)
    
    // Constraints in VML
//    let viewsDictionary = ["label1": label1, "label2": label2, "label3": label3, "label4": label4, "label5": label5]
//
//    for label in viewsDictionary.keys {
//      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
//      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: ["labelHeight": 120], views: viewsDictionary))
//    }
    
    // Same Constraints in Achor format
    var previous: UILabel?
    let labels = [label1, label2, label3, label4, label5]
    
    // multiplier gets factored in first then the constant. (the constraint below is 1/5 of the view - 10 points from that)
    let heightConstraint = labels.first!.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/5, constant: -10)
    heightConstraint.priority = UILayoutPriority(rawValue: 999)
    heightConstraint.isActive = true
    
    for label in labels {
      label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
      label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
      label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
      
      if let previous = previous {
        label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
        label.heightAnchor.constraint(equalTo: labels.first!.heightAnchor).isActive = true
    
      } else {
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
      }
      previous = label
    }
    
    labels.last?.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
  }


}

