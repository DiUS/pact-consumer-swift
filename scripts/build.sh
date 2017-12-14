#!/bin/bash

if [[ -z "${SCHEME}" ]]; then
  DESTINATION="OS=11.2,name=iPhone 8";
  SCHEME="PactConsumerSwift iOS";
fi

bundle exec fastlane scan --scheme "$SCHEME" --destination "$DESTINATION"

# # SwiftPM
# echo "#### Testing DEBUG configuration for SwiftPM compatibility ####"
# mkdir -p "${SRCROOT}/tmp"
# pact-mock-service start --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234
# swift build && swift test

# echo "#### Testing RELEASE configuration for SwiftPM compatibility ####"
# swift build -c release && swift test
# pact-mock-service stop
