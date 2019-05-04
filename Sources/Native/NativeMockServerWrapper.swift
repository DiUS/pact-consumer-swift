import Foundation
import SwiftyJSON
import BrightFutures

class NativeMockServerWrapper: MockServer {
  var port: Int32 = -1
  var pactDir: String = ""

  public init() {
    pactDir = defaultPactDir()
    port = randomPort()
  }

  func defaultPactDir() -> String {
    if let pactDir = ProcessInfo.processInfo.environment["pact_dir"] {
      return pactDir
    }
    return "/tmp/pacts"
  }

  func randomPort() -> Int32 {
    return Int32(arc4random_uniform(1000) + 4000)
  }

  public func getBaseUrl() -> String {
    return "http://localhost:\(port)"
  }

  public func setup(_ pact: Pact) -> Future<String, PactError> {
    return Future { complete in
      do {
        let payload = pact.payload()
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8)

        // iOS json generation adds extra backslashes to "application/json" --> "application\\/json"
        // causing the MockServer to fail to parse the file.
        let sanitizedString = jsonString!.replacingOccurrences(of: "\\/", with: "/")
        let result = create_mock_server_ffi(sanitizedString, port)
        if result < 0 {
          switch result {
          case -1:
            complete(.failure(.setupError("Mock server creation failed, pact supplied was nil")))
          case -2:
            complete(.failure(.setupError("Mock server creation failed, pact JSON file could not be parsed")))
          default:
            complete(.failure(.setupError("Mock server creation failed, result: \(result)")))
          }
        }
        print("Server started on port \(port)")
        complete(.success("Server started on port \(port)"))
      } catch let error as NSError {
        complete(.failure(.setupError(error.localizedDescription)))
      }
    }
  }

  public func verify(_ pact: Pact) -> Future<String, PactError> {
    return Future { complete in
      if !matched() {
        let message = mismatches()
        cleanup()
        complete(.failure(.missmatches(message)))
      } else {
        writeFile()
        cleanup()
        complete(.success("Pact verified successfully!"))
      }
    }
  }

  private func mismatches() -> String {
    let mismatches = mock_server_mismatches_ffi(port)
    if let mismatches = mismatches {
      let json = JSON(parseJSON: String(cString: mismatches))
      var mismatches = ""
      for (_, pathMismatch):(String, JSON) in json {
        mismatches = "\(mismatches)\(pathMismatch["method"]) \(pathMismatch["path"]): "
        for (_, mismatch):(String, JSON) in pathMismatch["mismatches"] {
          mismatches = "\(mismatches){error: \(mismatch["mismatch"]), "
          mismatches = "\(mismatches)expected: \(mismatch["expected"]), "
          mismatches = "\(mismatches)actual: \(mismatch["actual"])}"
        }
      }
      return mismatches
    } else {
      return "Nothing received"
    }
  }

  private func matched() -> Bool {
    return mock_server_matched_ffi(port)
  }

  private func writeFile() {
    write_pact_file_ffi(port, pactDir)
    print("notify: You can find the generated pact files here: \(self.pactDir)")
  }

  private func cleanup() {
    cleanup_mock_server_ffi(port)
  }
}
