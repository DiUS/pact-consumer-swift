
import XCTest
@testable import NativeMockServer

class NativeMockServerTests: XCTestCase {
  
  let pact = "{\n" +
    "\"provider\": {\n" +
    "  \"name\": \"Alice Service\"\n" +
    "},\n" +
    "\"consumer\": {\n" +
    "  \"name\": \"Consumer\"\n" +
    "},\n" +
    "\"interactions\": [\n" +
    "  {\n" +
    "    \"description\": \"a retrieve Mallory request\",\n" +
    "    \"request\": {\n" +
    "      \"method\": \"GET\",\n" +
    "      \"path\": \"/mallory\",\n" +
    "      \"query\": \"name=ron&status=good\"\n" +
    "    },\n" +
    "    \"response\": {\n" +
    "      \"status\": 200,\n" +
    "      \"headers\": {\n" +
    "        \"Content-Type\": \"text/html\"\n" +
    "      },\n" +
    "      \"body\": \"\\\"That is some good Mallory.\\\"\"\n" +
    "    }\n" +
    "  }\n" +
    "],\n" +
    "\"metadata\": {\n" +
    "  \"pact-specification\": {\n" +
    "    \"version\": \"1.0.0\"\n" +
    "  },\n" +
    "  \"pact-jvm\": {\n" +
    "    \"version\": \"1.0.0\"\n" +
    "  }\n" +
    "}\n" +
  "}\n"
  
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testMatchingExample() {
    let port = NativeMockServer.create_mock_server_ffi(pact, 0)
    print("starting test on port \(port)")
    
    let url = URL(string: "http://localhost:\(port)/mallory?name=ron&status=good")
    let expectation = self.expectation(description: "Swift Expectations")
    
    let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
      print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
      
      XCTAssertTrue(NativeMockServer.mock_server_matched_ffi(port))
      
      NativeMockServer.write_pact_file_ffi(port, nil)
      NativeMockServer.cleanup_mock_server_ffi(port)
      expectation.fulfill()
    })
    
    task.resume()
    waitForExpectations(timeout: 5.0, handler:nil)
  }
  
  func testMismatchExample() {
    let port = NativeMockServer.create_mock_server_ffi(pact, 0)
    print("starting test on port \(port)")
    let url = URL(string: "http://localhost:\(port)/mallory?name=ron&status=NoGood")
    let expectation = self.expectation(description: "Swift Expectations")
    
    let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
      print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
      
      XCTAssertFalse(NativeMockServer.mock_server_matched_ffi(port))
      let mismatchJson = String(cString: NativeMockServer.mock_server_mismatches_ffi(port))
      print("-----------Mismatches!--------")
      print(mismatchJson)
      print("------------------------------")
      
      NativeMockServer.cleanup_mock_server_ffi(port)
      expectation.fulfill()
    })
    
    task.resume()
    waitForExpectations(timeout: 5.0, handler:nil)
  }
}

