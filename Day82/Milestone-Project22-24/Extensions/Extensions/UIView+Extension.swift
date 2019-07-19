//
//  UIView+Extension.swift
//  Extensions
//
//  Created by Alexander on 7/19/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit

// Extend UIView so that it has a bounceOut(duration:) method that uses animation to scale its size down to 0.0001 over a specified number of seconds.
extension UIView {
  func bounceOut(duration: TimeInterval) {
    UIView.animate(withDuration: duration) { [unowned self] in
      self.frame.origin = CGPoint(x: self.frame.origin.x + self.frame.size.width / 2, y: self.frame.origin.y  + self.frame.size.height / 2)
      self.frame.size = CGSize(width: self.frame.size.width * 0.0001, height: self.frame.size.height * 0.0001)
    }
  }
}

// Extend Int with a times() method that runs a closure as many times as the number is high. For example, 5.times { print("Hello!") } will print “Hello” five times.
extension Int {
  func times(closure: () -> Void) {
    var numberOfTimes = self
    while numberOfTimes != 0 {
      closure()
      numberOfTimes -= 1
    }
  }
}

// Extend Array so that it has a mutating remove(item:) method. If the item exists more than once, it should remove only the first instance it finds. Tip: you will need to add the Comparable constraint to make this work!
extension Array where Element: Comparable {
  mutating func remove(item: Element) -> Element? {
    for (index, element) in self.enumerated() {
      if element == item {
        return self.remove(at: index)
      }
    }
    return nil
  }
}
