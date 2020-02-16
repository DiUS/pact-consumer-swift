import Quick
import Nimble
import PactConsumerSwift

class PactSwiftSSLSpec: QuickSpec {
  override func spec() {
    var animalMockService: MockService?
    var animalServiceClient: AnimalServiceClient?

    describe("tests fulfilling all expected interactions over HTTPS") {
      beforeEach {
        let pactVerificationService = PactVerificationService(
          url: "https://localhost",
          port: 2345,
          allowInsecureCertificates: true
        )

        animalMockService = MockService(
          provider: "Animal Service",
          consumer: "Animal Consumer Swift",
          pactVerificationService: pactVerificationService
        )
        
        animalServiceClient = AnimalServiceClient(baseUrl: animalMockService!.baseUrl)
      }

      it("gets an alligator") {
        animalMockService!.given("an alligator exists")
                          .uponReceiving("a request for all alligators")
                          .withRequest(method:.GET, path: "/alligators")
                          .willRespondWith(status: 200,
                                           headers: ["Content-Type": "application/json"],
                                           body: [ ["name": "Mary", "type": "alligator"] ])

        //Run the tests
        animalMockService!.run(timeout: 10000) { (testComplete) -> Void in
          animalServiceClient!.getAlligators( { (alligators) in
              expect(alligators[0].name).to(equal("Mary"))
              testComplete()
            }, failure: { (error) in
              testComplete()
          })
        }
      }
    }
  }
}
