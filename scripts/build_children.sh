#!/bin/bash

set -eu
set -o pipefail

REPO=${GITHUB_REPOSITORY:-""}

if [[ "${REPO}" != "DiUS/pact-consumer-swift" ]]; then
	echo "[INFO]: 👮 - Not the source repository DiUS/pact-consumer-swift... Skipping this step."
	exit 0
fi

TRAVISCI_AUTH_TOKEN=${AUTH_TOKEN:-"invalid_travis_ci_token"}
GITHUB_AUTH_TOKEN=${GH_BUILD_CHILDREN_TOKEN:-"invalid_github_token"}
COMMIT_MESSAGE=${COMMIT_MESSAGE:="repository dispatched"}
CLEAN_MESSAGE=`echo "${COMMIT_MESSAGE}" | head -1`

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
	  --data "{\"event_type\":\"triggered ${CLEAN_MESSAGE}\"}"
}

# GitHub Actions
# - <name> and <repo> must be lower-case!
echo "Triggering GitHub Actions"
triggerGitHubActionsBuild surpher/pactswiftpmexample
triggerGitHubActionsBuild surpher/pactmacosexample

# TravisCI
echo "Triggering TravisCI builds"
triggerTravisCIBuild andrewspinks%2FPactObjectiveCExample
triggerTravisCIBuild andrewspinks%2FPactSwiftExample
