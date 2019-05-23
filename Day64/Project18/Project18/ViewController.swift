//
//  ViewController.swift
//  Project18
//
//  Created by Alexander Kazakov on 5/24/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("I'm inside viewDidLoad() method!")
    print(1, 2, 3, 4, 5)
    print(1, 2, 3, 4, 5, separator: "-")
    print(1, 2, 3, 4, 5, terminator: "")
    print(" same line, new print statement")
    
    // Only execute in development (automatically disabled in release / live apps)
    assert(1 == 1, "Math failure!")
    //assert(1 == 2, "Brain failure!")
    
    for i in 1...100 {
      print("Got number \(i).")
    }
  }

  // Also Covered:
  // - Exception Breakpoints (from Breakpoint Navigator -> "+" add the bottom left corner of the panel, select exception breakpoint from the menu) - when enabled with stop execution at the breakpoint before the crash
  
  // - Adjust execution marker by moving it up or done in your code
  
  // - Add contions to breakpoints
  // - Execute commands on the lldb console

}

