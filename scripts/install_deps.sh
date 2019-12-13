#!/bin/bash
set -e

gem install xcpretty
brew update && brew bundle
carthage checkout
xcrun simctl list