Pod::Spec.new do |s|
  s.name         = "PactConsumerSwift"
  s.module_name  = "PactConsumerSwift"
  s.version = "0.5.3"
  s.summary      = "A Swift / ObjeciveC DSL for creating pacts."
  s.license      = { :type => 'MIT' }

  s.description  = <<-DESC
                    This library provides a Swift / Objective C DSL for creating Consumer [Pacts](http://pact.io).

                    Implements [Pact Specification v2](https://github.com/pact-foundation/pact-specification/tree/version-2),
                    including [flexible matching](http://docs.pact.io/documentation/matching.html).
                   DESC

  s.homepage     = "https://github.com/DiUS/pact-consumer-swift"

  s.author       = { "andrewspinks" => "andrewspinks@gmail.com", "markojustinek" => "mjustinek@dius.com.au" }

  s.ios.deployment_target   = '9.0'
  s.tvos.deployment_target  = '9.0'
  s.osx.deployment_target = '10.10'

  s.source       = { :git => "https://github.com/DiUS/pact-consumer-swift.git", :tag => "v#{s.version}" }
  s.source_files = 'Sources/**/*.swift'
  s.resources    = 'scripts/start_server.sh', 'scripts/stop_server.sh'
  s.requires_arc = true
  s.frameworks   = 'XCTest'

  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'BrightFutures', '~> 7.0'
  s.dependency 'Nimble', '~> 8.0'
  s.dependency 'Quick', '~> 2.0'
end
