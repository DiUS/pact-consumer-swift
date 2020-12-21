#!/bin/bash

set -eu
set -o pipefail

TRAVISCI_AUTH_TOKEN=${AUTH_TOKEN:="invalid"}
GITHUB_AUTH_TOKEN=${GH_BUILD_CHILDREN_TOKEN:="invalid"}
COMMIT_MESSAGE=${COMMIT_MESSAGE:="repository_dispatched"}

function triggerTravisCIBuild {
  curl -s -X POST --silent --show-error --fail \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token ${TRAVISCI_AUTH_TOKEN}" \
    -d "{"request": {"branch":"master"}}" \
    https://api.travis-ci.org/repo/$1/requests
}

function triggerGitHubActionsBuild {
	curl -X POST --silent --show-error --fail \
	https://api.github.com/repos/$1/dispatches \
	-H "Accept: application/vnd.github.everest-preview+json" \
	-H "Content-Type: application/json" \
	-H "Authorization: token $GITHUB_AUTH_TOKEN" \
	--data "{\"event_type\":\"pact-consumer-swift - ${COMMIT_MESSAGE}\"}"
}

# GitHub Actions
# - <name> and <repo> must be lower-case!
triggerGitHubActionsBuild surpher/pactswiftpmexample
triggerGitHubActionsBuild surpher/pactmacosexample

# TravisCI
triggerTravisCIBuild andrewspinks%2FPactObjectiveCExample
triggerTravisCIBuild andrewspinks%2FPactSwiftExample
