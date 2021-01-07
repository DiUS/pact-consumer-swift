#!/bin/bash

set -eu
set -o pipefail

TRAVISCI_AUTH_TOKEN=${AUTH_TOKEN:-"invalid_travis_ci_token"}
GITHUB_AUTH_TOKEN=${GH_BUILD_CHILDREN_TOKEN:-"invalid_github_token"}
COMMIT_MESSAGE=${COMMIT_MESSAGE:="repository_dispatched"}
COMMIT_MESSAGE_FIRST_LINE_ONLY=`echo "${COMMIT_MESSAGE}" | head -1`

function triggerTravisCIBuild {
  curl -s -X POST --silent --show-error --fail \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token ${TRAVISCI_AUTH_TOKEN}" \
    -d "{\"request\": {\"branch\":\"master\"}}" \
    https://api.travis-ci.org/repo/$1/requests
}

function triggerGitHubActionsBuild {
	curl -X POST --silent --show-error --fail \
	https://api.github.com/repos/$1/dispatches \
	-H "Accept: application/vnd.github.everest-preview+json" \
	-H "Content-Type: application/json" \
	-u ${GITHUB_AUTH_TOKEN} \
	--data "{\"event_type\":\"triggered ${COMMIT_MESSAGE_FIRST_LINE_ONLY}\"}"
}

# GitHub Actions
# - <name> and <repo> must be lower-case!
triggerGitHubActionsBuild surpher/pactswiftpmexample
triggerGitHubActionsBuild surpher/pactmacosexample

# TravisCI
triggerTravisCIBuild andrewspinks%2FPactObjectiveCExample
triggerTravisCIBuild andrewspinks%2FPactSwiftExample
