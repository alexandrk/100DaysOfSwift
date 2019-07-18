//: [Previous](@previous)

import Foundation

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

extension String {
  func containsAny(of array: [String]) -> Bool {
    for item in array {
      if self.contains(item) {
        return true
      }
    }
    
    return false
  }
}
input.containsAny(of: languages)

// Another way of finding if any of the String elements of the array is a part of a String, is as follows:

// Passing `.contains(:)` method of a String to .contains(where:) method of array
// This works since the signature of the .contains(:) String method matches the signature expected by the closure
languages.contains(where: input.contains)

//: [Next](@next)
