import Foundation
import SwiftyJSON
import BrightFutures

public class NativeMockServerWrapper: MockServer {
  var port: Int32 = -1
  let pactDir: String = ProcessInfo.processInfo.environment["pact_dir"] ?? "/tmp/pacts"
  let shouldWritePacts: Bool

  public init(shouldWritePacts: Bool = false) {
    self.shouldWritePacts = shouldWritePacts
    port = randomPort()
  }

  func randomPort() -> Int32 {
    return Int32(arc4random_uniform(2000) + 4000)
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
        let result = createServerOnUnusedPort(withJson: sanitizedString)
        if result < 0 {
          switch result {
          case -1:
            complete(.failure(.setupError("Mock server creation failed, pact supplied was nil")))
          case -2:
            complete(.failure(.setupError("Mock server creation failed, pact JSON file could not be parsed")))
          case -4:
            complete(.failure(.setupError("Mock server creation failed, Address already in use")))
          default:
            complete(.failure(.setupError("Mock server creation failed, result: \(result)")))
          }
          return
        }
        print("Server started on port \(port)")
        complete(.success("Server started on port \(port)"))
      } catch let error as NSError {
        complete(.failure(.setupError(error.localizedDescription)))
      }
    }
  }

  private func createServerOnUnusedPort(withJson sanitizedString: String) -> Int32 {
    var result = create_mock_server_ffi(sanitizedString, port)
    var count = 0
    while result == -4 && count < 25 {
        print("Port: \(port) already in use")
        port = randomPort()
        print("Re-trying on: \(port)")
        result = create_mock_server_ffi(sanitizedString, port)
        count += 1
    }
    return result
  }

  public func verify(_ pact: Pact) -> Future<String, PactError> {
    return Future { complete in
      if !matched() {
        let message = mismatches()
        cleanup()
        complete(.failure(.missmatches(message)))
      } else {
        let result = writeFile()
        cleanup()
        if result > 0 {
          switch result {
          case 2:
            complete(.failure(.writeError("The pact file was not able to be written")))
          case 3:
            complete(.failure(.writeError("A mock server with the provided port was not found")))
          case 4:
            complete(.success("Pact verified successfully but was not written!"))
          default:
            complete(.failure(.writeError("Writing file failed, result: \(result)")))
          }
          return
        }
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

  private func writeFile() -> Int32 {
    guard shouldWritePacts, checkForPath() else {
        return 4
    }
    let result = write_pact_file_ffi(port, pactDir)
    print("notify: You can find the generated pact files here: \(self.pactDir)")
    return result
  }

    private func checkForPath() -> Bool {
        guard !FileManager.default.fileExists(atPath: pactDir) else {
            return true
        }
        print("notify: Path not found: \(self.pactDir)")
        return couldCreatePath()
    }

    private func couldCreatePath() -> Bool {
        var couldBeCreated = false
        do {
            try FileManager.default.createDirectory(atPath: self.pactDir, withIntermediateDirectories: false, attributes: nil)
            couldBeCreated = true
        } catch let error as NSError {
            print("notify: Files not written. Path couldn't be created: \(self.pactDir)")
            print(error.localizedDescription)
        }
        return couldBeCreated
    }

  private func cleanup() {
    cleanup_mock_server_ffi(port)
    print("Server closed on port \(port)")
  }
}
