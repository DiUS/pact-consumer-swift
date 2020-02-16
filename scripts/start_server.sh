#!/bin/bash

mkdir -p "${SRCROOT}/tmp"

pact-mock-service start --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234
pact-mock-service start --ssl --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact-ssl.log" --pact-dir "${SRCROOT}/tmp/pacts-ssl" -p 2345
