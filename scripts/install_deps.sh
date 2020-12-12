#!/bin/bash
set -e

gem install xcpretty
brew tap thii/xcbeautify https://github.com/thii/xcbeautify.git
brew install swiftlint xcbeautify
brew update && brew bundle
carthage checkout
