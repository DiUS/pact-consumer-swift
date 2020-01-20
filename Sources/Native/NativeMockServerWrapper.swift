import Foundation
import SwiftyJSON
import BrightFutures

public class NativeMockServerWrapper: MockServer {
    private lazy var port: Int32 = {
        return findUnusedPort()
    }()
    private let pactDir: String = ProcessInfo.processInfo.environment["pact_dir"] ?? "/tmp/pacts"
    private let shouldWritePacts: Bool

    public init(shouldWritePacts: Bool = false) {
        self.shouldWritePacts = shouldWritePacts
    }

    private func findUnusedPort() -> Int32 {
        var port = randomPort
        var (unused, description) = checkTcpPortForListen(port: port)
        while !unused {
            debugPrint(description)
            port = randomPort
            (unused, description) = checkTcpPortForListen(port: port)
        }
        debugPrint(description)
        return Int32(port)
    }

    private var randomPort: in_port_t {
        return in_port_t(arc4random_uniform(2000) + 4000)
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
                    case -4:
                        complete(.failure(.setupError("Mock server creation failed, Address already in use")))
                    default:
                        complete(.failure(.setupError("Mock server creation failed, result: \(result)")))
                    }
                    return
                }
                debugPrint("Server started on port \(port)")
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
        debugPrint("notify: You can find the generated pact files here: \(self.pactDir)")
        return result
    }
}

// NOTE: split of filesystem checkings as extension
extension NativeMockServerWrapper {
    private func checkForPath() -> Bool {
        guard !FileManager.default.fileExists(atPath: pactDir) else {
            return true
        }
        debugPrint("notify: Path not found: \(self.pactDir)")
        return couldCreatePath()
    }

    private func couldCreatePath() -> Bool {
        var couldBeCreated = false
        do {
            try FileManager.default.createDirectory(atPath: self.pactDir,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
            couldBeCreated = true
        } catch let error as NSError {
            debugPrint("notify: Files not written. Path couldn't be created: \(self.pactDir)")
            debugPrint(error.localizedDescription)
        }
        return couldBeCreated
    }

    private func cleanup() {
        // NOTE: cleanup_mock_server_ffi doesn't work how it's supposed to. the port is still blocked afterwards
        // I'll see if there's a way to fix that and also increased the random range for the ports to reduce collisions
        let result = cleanup_mock_server_ffi(port)
        debugPrint("Server closed on port \(port), result: \(result)")
        //    debugPrint(checkTcpPortForListen(port: in_port_t(port)))
    }
}

// NOTE: split of network port checkings as extension
// used code from: https://stackoverflow.com/a/49728137
private extension NativeMockServerWrapper {
    func checkTcpPortForListen(port: in_port_t) -> (Bool, descr: String) {

        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return (false, "SocketCreationFailed, \(descriptionOfLastError())")
        }

        var addr = sockaddr_in()
        let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
        addr.sin_len = __uint8_t(sizeOfSockkAddr)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))

        if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
            let details = descriptionOfLastError()
            release(socket: socketFileDescriptor)
            return (false, "\(port), BindFailed, \(details)")
        }
        if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
            let details = descriptionOfLastError()
            release(socket: socketFileDescriptor)
            return (false, "\(port), ListenFailed, \(details)")
        }
        release(socket: socketFileDescriptor)
        return (true, "\(port) is free for use")
    }

    func release(socket: Int32) {
        Darwin.shutdown(socket, SHUT_RDWR)
        close(socket)
    }

    func descriptionOfLastError() -> String {
        return String.init(cString: (UnsafePointer(strerror(errno))))
    }
}
