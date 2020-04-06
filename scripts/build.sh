#!/bin/bash
set -e

if [[ -z "${PROJECT_NAME}" ]]; then
  PROJECT_NAME="PactConsumerSwift.xcodeproj";
  DESTINATION="OS=13.3,name=iPhone 11";
  SCHEME="PactConsumerSwift iOS";
  CARTHAGE_PLATFORM="iOS";
fi

# Carthage - build dependencies
carthage build --no-use-binaries --platform $CARTHAGE_PLATFORM 

# SwiftPM
echo "#### Testing DEBUG configuration for SwiftPM compatibility ####"
swift build

# Build and test - debug
echo "#### Testing DEBUG configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify\""
set -o pipefail && xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify

# Build and test - release
echo "#### Testing RELEASE configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify\""
set -o pipefail && xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify

# Carthage - test that the lot builds for Carthage
carthage build pact-consumer-swift --no-skip-current --no-use-binaries --platform $CARTHAGE_PLATFORM 