#!/bin/bash

KEYCHAIN=ios-build.keychain

if [ -z "$KEY_PASSWORD" ]
then
    exit 0
fi

security delete-keychain "$KEYCHAIN"
