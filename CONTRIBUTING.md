# Contributing to Pact Consumer Swift project

### Prepare your development environment
The Pact Consumer Swift library is using Carthage and Swift Package Manager to manage library dependencies. You should install [Carthage](https://github.com/Carthage/Carthage) using [Homebrew](https://brew.sh), then download and build the dependencies using `carthage bootstrap` (Carthage), or `swift package resolve` (SwiftPM).

##### Setup
```
gem install xcpretty
```

### Running tests with default destination
```
./scripts/build.sh
```
defaults to iOS 11 on iPhone 8

### Running specific platform tests
iOS 10.3 on iPhone 7:  
```
xcodebuild -project PactConsumerSwift.xcodeproj -scheme "PactConsumerSwift iOS" -destination "OS=10.3,name=iPhone 7" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty;
```

for macOS:  
```
xcodebuild -project PactConsumerSwift.xcodeproj -scheme "PactConsumerSwift macOS" -destination "arch=x86_64" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty;
```

for tvOS:
```
xcodebuild -project PactConsumerSwift.xcodeproj -scheme PactConsumerSwift tvOS -destination OS=11.0,name=Apple TV 4K (at 1080p) -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty;
```

#### Test CocoaPods
```
pod spec lint PactConsumerSwift.podspec --allow-warnings
```

Getting set up to work with [CocoaPods](https://guides.cocoapods.org/making/getting-setup-with-trunk.html).

#### Test Carthage
```
carthage build --no-skip-current --platform iOS,macOS
```

#### Test Swift Package Manager
```
./scripts/start_server.sh &&
swift build &&
swift test &&
./scripts/stop_server.sh
```
For more information, see the [.travis.yml](/.travis.yml) configuration.

### TravisCI
Builds on [Travis CI](https://travis-ci.org/DiUS/pact-consumer-swift/) with pipeline configuration in [.travis.yml](/.travis.yml).

### Release
[release.groovy](/release.groovy) script helps with updating the Changelog, tagging the commit with a release version, and publish to Cocoapods.
```
groovy release.groovy
```
