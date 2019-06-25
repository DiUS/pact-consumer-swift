#!/bin/bash

body='{
"request": {
"branch":"master"
}}'

function triggerBuild {
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token $AUTH_TOKEN" \
    -d "$body" \
    https://api.travis-ci.org/repo/$1/requests
}

triggerBuild andrewspinks%2FPactObjectiveCExample
triggerBuild andrewspinks%2FPactSwiftExample
triggerBuild surpher%2FPactSwiftPMExample
triggerBuild surpher%2FPactMacOSExample
