#!/bin/bash
set -e

if [[ -z "${PROJECT_NAME}" ]]; then
	if [[ "$*" == "macos" ]] || [[ "$*" == "macOS" ]]; then
		PROJECT_NAME="PactConsumerSwift.xcodeproj";
		DESTINATION="arch=x86_64";
		SCHEME="PactConsumerSwift macOS";
		CARTHAGE_PLATFORM="macos";
 	else
		PROJECT_NAME="PactConsumerSwift.xcodeproj";
		DESTINATION="OS=14.2,name=iPhone 12 Pro";
		SCHEME="PactConsumerSwift iOS";
		CARTHAGE_PLATFORM="iOS";
 	fi
fi

SCRIPTS_DIR="${BASH_SOURCE[0]%/*}"

# Build Carthage dependencies
$SCRIPTS_DIR/carthage_xcode12 update --platform $CARTHAGE_PLATFORM
# carthage update --platform $CARTHAGE_PLATFORM

# Carthage - debug
echo "#### Testing scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"set -o pipefail && xcodebuild clean test -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcbeautify\""
set -o pipefail && xcodebuild clean test -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Debug GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcbeautify

# Carthage - release
echo "#### Testing RELEASE configuration for scheme: $SCHEME, with destination: $DESTINATION ####"
echo "Running: \"set -o pipefail && xcodebuild clean test -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES ONLY_ACTIVE_ARCH=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES ENABLE_TESTABILITY=YES | xcbeautify\""
set -o pipefail && xcodebuild clean test -project $PROJECT_NAME -scheme "$SCHEME" -destination "$DESTINATION" -configuration Release GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES ONLY_ACTIVE_ARCH=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES ENABLE_TESTABILITY=YES | xcbeautify