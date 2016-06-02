#!/bin/bash

mkdir -p "${SRCROOT}/tmp"
which pact-mock-service

pact-mock-service start --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234
