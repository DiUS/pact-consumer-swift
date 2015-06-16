Pod::Spec.new do |s|
  s.name         = "PactConsumerSwift"
  s.version      = "0.1.2"
  s.summary      = "A Swift / ObjeciveC DSL for creating pacts."

  s.description  = <<-DESC
                   This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact README first.

                   This DSL relies on the Ruby pact-mock_service gem to provide the mock service for the iOS tests.
                   DESC

  s.homepage     = "https://github.com/DiUS/pact-consumer-swift"

  s.author       = { "andrewspinks" => "andrewspinks@gmail.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/DiUS/pact-consumer-swift.git", :tag => s.version }
  s.source_files = 'PactConsumerSwift/**/*.swift'
  s.resources = 'scripts/start_server.sh', 'scripts/stop_server.sh'
  s.requires_arc = true
  s.frameworks   = 'Foundation', 'UIKit', 'XCTest'

  s.requires_arc = true

  s.dependency 'Alamofire'
  s.dependency 'BrightFutures'
end
