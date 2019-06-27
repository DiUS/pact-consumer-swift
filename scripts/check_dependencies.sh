#!/bin/bash
set -e

if which pact-mock-service >/dev/null; then
    echo "Dependencies check:"
    echo "- pact-mock-service: installed"
else
    echo "Dependencies check:" 
    echo "- pact-mock-service: not found!"
    echo ""
    echo "### ERROR ###"
    echo "pact-mock-service is not installed! See https://github.com/pact-foundation/pact-ruby-standalone or use Homebrew tap \"pact-foundation/pact-ruby-standalone\""
fi