//: [Previous](@previous)

import Foundation

// 1. Method that adds prefix to a string, if it doesn't contain it already
extension String {
  func withPrefix(prefix: String) -> String {
    return self.hasPrefix(prefix) ? self : prefix + self
  }
}

// 2. Check if the string is any kind of number
extension String {
  func isNumeric() -> Bool {
    return Double(self) != nil
  }
}

// 3. Property that returns lines in a form of array (lines are broken up by the presence of the "\n" character)
extension String {
  var lines: [String] {
    return self.split(separator: "\n").map { String($0) }
  }
}

var str = "car"
str.withPrefix(prefix: "flex")

var numericString = "122390.123"
numericString.isNumeric()

var multilineString = "This is a\nTest\nLine number 3"
multilineString.lines

//: [Next](@next)
