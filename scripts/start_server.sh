#!/bin/bash

mkdir "${SRCROOT}/tmp"
which pact-mock-service

nohup pact-mock-service execute --log "${SRCROOT}/tmp/pact.log" --pact-dir "${SRCROOT}/tmp/pacts" -p 1234 > ~/nohup.out 2>&1 &
PID=$!

sleep 3
cat ~/nohup.out

echo "Started pact server on pid: ${PID}"

if [ -z $PID ]; then
	echo "Could not start pact server"
	exit 0
fi

echo $PID > "${SRCROOT}/tmp/pact-server.pid"
echo 'Wating for pact mock server to start.'
until $(curl --output /dev/null --silent -H "X-Pact-Mock-Service: true" http://localhost:1234/interactions/verification); do
    printf '.'
    sleep 1
done
