#!/bin/bash

# GitHub Hosted runners are complaining about re-installing Swiftlint using brew.
if [[ "$CI" == true ]]; then
	# Explicitly install only pact-ruby-standalone and xcbeautify, other tools are already installed on the GitHub hosted runner
	brew tap 'pact-foundation/pact-ruby-standalone'
	brew tap 'thii/xcbeautify'
	brew install 'pact-ruby-standalone'
	brew install 'xcbeautify'
else
	# Install dependencies using Brewfile
	brew update && brew bundle
	carthage checkout
fi
