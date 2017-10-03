#!/bin/bash

if [[ -z "${PROJECT_NAME}" ]]; then
  PROJECT_NAME="PactConsumerSwift.xcodeproj";
  DESTINATION="OS=11.0,name=iPhone 8";
  SCHEME="PactConsumerSwift iOS";
fi

# Carthage - debug
echo "#### Testing DEBUG configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty -c;\""
xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty -c;

# Carthage - release
echo "#### Testing RELEASE configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty -c;\""
xcodebuild -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty -c;

# SwiftPM
echo "#### Testing DEBUG configuration for SwiftPM compatibility ####"
mkdir -p "${SRCROOT}/tmp"
pact-mock-service start --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234
swift build && swift test

echo "#### Testing RELEASE configuration for SwiftPM compatibility ####"
swift build -c release && swift test
pact-mock-service stop
