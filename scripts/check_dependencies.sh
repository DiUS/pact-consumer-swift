#!/bin/bash
set -eu

PACT_MOCK_SERVICE=pact-mock-service

echo "Test Dependencies check:"

if which $PACT_MOCK_SERVICE >/dev/null; then
    echo "- $PACT_MOCK_SERVICE: installed"
else
    echo "- $PACT_MOCK_SERVICE: not found!"
    echo ""
    echo "error: $PACT_MOCK_SERVICE is not installed!"
    echo "See https://github.com/pact-foundation/pact-ruby-standalone or use Homebrew tap \"pact-foundation/pact-ruby-standalone\""
    exit 1
fi