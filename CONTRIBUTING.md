# Contributing to Pact Consumer Swift

### Prepare development environment
The Pact Consumer Swift library is using carthage to manage library dependencies. You can install carthage using homebrew, then download and build the dependencies using `carthage bootstrap`

### Running tests
iOS 11.0 on iPhone 8:  
```
xcodebuild -project PactConsumerSwift.xcodeproj -scheme "PactConsumerSwift iOS" -destination "OS=11.0,name=iPhone 8" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty;
```

macOS:  
```
xcodebuild -project PactConsumerSwift.xcodeproj -scheme "PactConsumerSwift macOS" -destination "arch=x86_64" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty;
```

#### Test Carthage compatibility
```
carthage build --no-skip-current --platform iOS,macOS
```

#### Test Swift Package Manager build
```
./scripts/start_server.sh &&
swift build &&
./scripts/stop_server.sh
```

For more information, see the [.travis.yml](/.travis.yml)
