import Foundation
@testable import PactConsumerSwift

class VerifiableHttpStub {
    public var requestExecuted = false
    public var requestBody: String?
    
    public var responseBody: Data = Data()
    public var responseCode: Int = 0
    
    public init() { }
    
    public init(responseCode: Int, response: String) {
        self.responseCode = responseCode
        self.responseBody = response.data(using: .utf8) ?? Data()
    }
}

enum RubyMockServiceRequest: CaseIterable {
    case cleanInteractions
    case setupInteractions
    case verifyInteractions
    case writePact
    
    init?(request: URLRequest) {
        guard let mockRequest = RubyMockServiceRequest.allCases.filter({
            request.httpMethod?.uppercased() == $0.route.method.uppercased()
                && request.url?.path == $0.route.path
        }).first else {
            return nil
        }
        self = mockRequest
    }
    
    private var route: PactVerificationService.Router {
        switch self {
        case .cleanInteractions:
            return .clean
        case .setupInteractions:
            return .setup([:])
        case .verifyInteractions:
            return .verify
        case .writePact:
            return .write([:])
        }
    }
}

class StubProtocol: URLProtocol {
    static var stubs: [RubyMockServiceRequest:VerifiableHttpStub] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override func startLoading() {
        guard let url = request.url else { fatalError("A request should always have an URL") }

        guard
            let mockRequest = RubyMockServiceRequest(request: request),
            let stub: VerifiableHttpStub = StubProtocol.stubs[mockRequest] else {
                // Nothing registered, just return a 200
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocolDidFinishLoading(self)
                return
        }
        
        StubProtocol.stubs[mockRequest]?.requestExecuted = true
        StubProtocol.stubs[mockRequest]?.requestBody = request.body
        
        let response = HTTPURLResponse(url: url, statusCode: stub.responseCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.responseBody)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }
    
}

struct RubyPactMockServiceStub {
    var cleanStub: VerifiableHttpStub { StubProtocol.stubs[.cleanInteractions] ?? .init() }
    var setupInteractionsStub: VerifiableHttpStub { StubProtocol.stubs[.setupInteractions] ?? .init() }
    var verifyInteractionsStub: VerifiableHttpStub { StubProtocol.stubs[.verifyInteractions] ?? .init() }
    var writePactStub: VerifiableHttpStub { StubProtocol.stubs[.writePact] ?? .init() }
    
    let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubProtocol.self]
        self.session = URLSession.init(configuration: configuration)
    }
    
    @discardableResult
    func clean(responseCode: Int,
               response: String) -> RubyPactMockServiceStub {
        StubProtocol.stubs[.cleanInteractions] = .init(responseCode: responseCode, response: response)
        return self
    }
    
    @discardableResult
    func cleanWithError(errorMessage: String) -> RubyPactMockServiceStub {
        StubProtocol.stubs[.cleanInteractions] = .init(responseCode: 500, response: errorMessage)
        return self
    }
    
    @discardableResult
    func setupInteractions(responseCode: Int,
                           response: String) -> RubyPactMockServiceStub {
        StubProtocol.stubs[.setupInteractions] = .init(responseCode: responseCode, response: response)
        return self
    }
    
    @discardableResult
    func verifyInteractions(responseCode: Int,
                            response: String) -> RubyPactMockServiceStub {
        StubProtocol.stubs[.verifyInteractions] = .init(responseCode: responseCode, response: response)
        return self
    }
    
    @discardableResult
    func writePact(responseCode: Int,
                   response: String) -> RubyPactMockServiceStub {
        StubProtocol.stubs[.writePact] = .init(responseCode: responseCode, response: response)
        return self
    }
    
    func reset() {
        StubProtocol.stubs = [:]
    }
}

extension URLRequest {
    var body: String? {
        guard let input = httpBodyStream else { return nil }
        
        var data = Data()
        
        input.open()
        defer {
            input.close()
        }
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read <= 0 {
                break
            }
            data.append(buffer, count: read)
        }
        
        return String(data: data, encoding: .utf8)
    }
}
