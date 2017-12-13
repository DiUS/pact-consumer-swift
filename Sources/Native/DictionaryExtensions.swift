import Foundation

extension Dictionary {
  public func merge(dictionary: [Key: Value]) -> [Key: Value] {
    var newDictionary: [Key: Value] = self
    for (key, value) in dictionary {
      newDictionary[key] = value
    }
    return newDictionary
  }
}
