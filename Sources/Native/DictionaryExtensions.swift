import Foundation

extension Dictionary {
  public func merge(dictionary: [Key: Value]) -> [Key: Value] {
    var newDictionary: [Key: Value] = self
    for (dictKey, value) in dictionary {
      newDictionary[dictKey] = value
    }
    return newDictionary
  }
}
