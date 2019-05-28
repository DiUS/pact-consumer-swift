#!/bin/bash

if [[ -z "${SCHEME}" ]]; then
  DESTINATION="OS=11.4,name=iPhone 8";
  SCHEME="PactConsumerSwift iOS";
  CARTHAGE_PLATFORM="iOS"
fi

swiftlint
carthage build --no-skip-current --platform $CARTHAGE_PLATFORM
bundle exec fastlane scan --scheme "$SCHEME" --destination "$DESTINATION"

# # SwiftPM
# echo "#### Testing DEBUG configuration for SwiftPM compatibility ####"
# mkdir -p "${SRCROOT}/tmp"
# pact-mock-service start --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234
# swift build && swift test

# echo "#### Testing RELEASE configuration for SwiftPM compatibility ####"
# swift build -c release && swift test
# pact-mock-service stop
