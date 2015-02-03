#!/bin/bash

mkdir "${SRCROOT}/tmp"
which pact-mock-service

nohup pact-mock-service start --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234 > ~/nohup.out 2>&1 &
