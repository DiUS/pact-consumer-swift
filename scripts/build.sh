#!/bin/bash

xcodebuild -workspace PactConsumerSwift.xcworkspace -scheme PactConsumerSwift test -destination 'platform=iOS Simulator,OS=10.0,name=iPhone 6' -sdk iphonesimulator | xcpretty -c
