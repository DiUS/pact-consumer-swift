import Foundation

class NetworkLogger {
  static func log(request: URLRequest) {

    print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
    defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }

    let urlAsString = request.url?.absoluteString ?? ""
    let urlComponents = NSURLComponents(string: urlAsString)

    let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
    let path = "\(urlComponents?.path ?? "")"
    let query = "\(urlComponents?.query ?? "")"
    let host = "\(urlComponents?.host ?? "")"

    var logOutput = """
    \(urlAsString) \n\n
    \(method) \(path)?\(query) HTTP/1.1 \n
    HOST: \(host)\n
    """

    _ = request.allHTTPHeaderFields?.map { logOutput += "\($0): \($1) \n" }

    if let body = request.httpBody {
      logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
    }

    debugPrint(logOutput)
  }

  static func log(response: URLResponse) { }
}

