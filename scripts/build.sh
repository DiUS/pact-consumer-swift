#!/bin/bash
set -e

if [[ -z "${PROJECT_NAME}" ]]; then
  PROJECT_NAME="PactConsumerSwift.xcodeproj";
  DESTINATION="OS=13.0,name=iPhone 8";
  SCHEME="PactConsumerSwift iOS";
  CARTHAGE_PLATFORM="iOS";
fi

# Build Carthage dependencies
carthage build --platform $CARTHAGE_PLATFORM

# SwiftPM
echo "#### Testing DEBUG configuration for SwiftPM compatibility ####"
swift build

# Carthage - debug
echo "#### Testing DEBUG configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify\""
set -o pipefail && xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify

# Carthage - release
echo "#### Testing RELEASE configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify\""
set -o pipefail && xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcbeautify

# Test the lot that it builds for Carthage
carthage build --no-skip-current --platform $CARTHAGE_PLATFORM
