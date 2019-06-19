import Foundation

class Router<EndPoint: EndPointType>: NetworkRouter {

  private var task: URLSessionTask?

  func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
    let session = URLSession.shared
    do {
      let request = try self.buildRequest(from: route)
      if route.networkLogging { NetworkLogger.log(request: request) }
      task = session.dataTask(with: request, completionHandler: { data, response, error in
        completion(data, response, error)
      })
    } catch {
      completion(nil, nil, error)
    }
    self.task?.resume()
  }

  func cancel() {
    self.task?.cancel()
  }

  // MARK: -

  fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {

    var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 300.0)

    request.httpMethod = route.httpMethod.rawValue

    addHeaders(route.headers, request: &request)

    do {
      switch route.task {
      case .request:
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      case .requestWithParameters(let bodyParameters, let urlParameters, let headers):
        self.addHeaders(headers, request: &request)
        try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
      }
      return request
    } catch {
      throw error
    }
  }

  fileprivate func configureParameters(
    bodyParameters: Parameters?,
    urlParameters: Parameters?,
    request: inout URLRequest
  ) throws {
    do {
      if let bodyParameters = bodyParameters {
        try JSONParameterEncoder().encode(urlRequest: &request, with: bodyParameters)
      }
      if let urlParameters = urlParameters {
        try URLParameterEncoder().encode(urlRequest: &request, with: urlParameters)
      }
    } catch {
      throw error
    }
  }

  fileprivate func addHeaders(_ headers: HTTPHeaders?, request: inout URLRequest) {
    guard let headers = headers else { return }
    _ = headers.map { request.setValue($1, forHTTPHeaderField: $0) }
  }
}
