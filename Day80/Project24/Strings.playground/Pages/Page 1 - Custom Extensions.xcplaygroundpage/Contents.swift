let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
  // remove a prefix if it exists
  func deletingPrefix(_ prefix: String) -> String {
    guard self.hasPrefix(prefix) else { return self }
    return String(self.dropFirst(prefix.count))
  }
  
  // remove a suffix if it exists
  func deletingSuffix(_ suffix: String) -> String {
    guard self.hasSuffix(suffix) else { return self }
    return String(self.dropLast(suffix.count))
  }
}
