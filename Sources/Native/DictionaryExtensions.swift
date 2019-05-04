import Foundation

extension Dictionary {
  public func merge(dictionary: [Key: Value]) -> [Key: Value] {
    var newDictionary: [Key: Value] = self
    // FIXME: renamed key, check if context checks out
    for (mergedKey, value) in dictionary {
      newDictionary[mergedKey] = value
    }
    return newDictionary
  }
}
