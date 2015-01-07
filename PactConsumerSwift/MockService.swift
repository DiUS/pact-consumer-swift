import Foundation
import Alamofire

public class MockService {
    private let provider: String
    private let consumer: String
    private let url: String
    private let port: Int
    private var interactions: [Interaction] = []
    
    public init(provider: String, consumer: String, url: String = "http://localhost", port: Int = 1234) {
        self.provider = provider
        self.consumer = consumer
        self.url = url
        self.port = port
    }
    
    public func given(providerState: String) -> Interaction {
        var interaction = Interaction().given(providerState)
        interactions.append(interaction)
        return interaction
    }
    
    public func uponReceiving(description: String) -> Interaction {
        var interaction = Interaction().uponReceiving(description)
        interactions.append(interaction)
        return interaction
    }
    
    public func run(testFunction: (cleanup: () -> Void) -> Void) {
        testFunction({() in
            // cleanup
        })
    }
    
}