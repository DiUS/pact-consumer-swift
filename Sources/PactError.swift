import Foundation

public enum PactError: Error {
  case setupError(String)
  case executionError(String)
  case missmatches(String)
  case writeError(String)

    var message: String {
        switch self {
        case .setupError(let message), .executionError(let message), .missmatches(let message), .writeError(let message):
          return message
        }
    }

    var localizedDescription: String {
        switch self {
        case .setupError:
            return "Error setting up pact: \(message)"
        case .executionError:
            return "Error executing pact: \(message)"
        case .missmatches:
            return "Verification error (check build log for mismatches): \(message)"
        case .writeError:
            return "Error writing pact: \(message)"
        }
    }
}
