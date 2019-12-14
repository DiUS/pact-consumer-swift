import Foundation

extension NSError {

  static func prepareWith(userInfo: [String: Any]) -> NSError {
    NSError(domain: "error", code: 0, userInfo: userInfo)
  }

  static func prepareWith(message: String) -> NSError {
    NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: message, comment: "")]) //swiftlint:disable:this line_length
  }

  static func prepareWith(data: Data) -> NSError {
    NSError(
      domain: "error",
      code: 0,
      userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Error", value: "\(String(data: data, encoding: .utf8) ?? "Failed to cast response Data into String")", //swiftlint:disable:this line_length
        comment: "")
      ]
    )
  }

}
