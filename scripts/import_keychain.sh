#!/bin/bash

export SCRIPT_DIR=$(dirname "$0")

##
## Configuration Variables
##

# The name of the keychain to create for iOS code signing.
KEYCHAIN=ios-build.keychain

# If this environment variable is missing, we must not be running on Travis.
if [ -z "$KEY_PASSWORD" ]
then
    exit 0
fi

echo "*** Setting up code signing..."
password=cibuild

# Create a temporary keychain for code signing.
security create-keychain -p "$password" "$KEYCHAIN"
security default-keychain -s "$KEYCHAIN"
security unlock-keychain -p "$password" "$KEYCHAIN"
security set-keychain-settings -t 3600 -l "$KEYCHAIN"

# Download the certificate for the Apple Worldwide Developer Relations
# Certificate Authority.
certpath="$SCRIPT_DIR/apple_wwdr.cer"
curl 'https://developer.apple.com/certificationauthority/AppleWWDRCA.cer' > "$certpath"
security import "$certpath" -k "$KEYCHAIN" -T /usr/bin/codesign

# Import our development certificate.
security import "certificates/development.p12" -k "$KEYCHAIN" -P "$KEY_PASSWORD" -T /usr/bin/codesign
