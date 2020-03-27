#!/bin/sh
set -eu

# Set default swiftlint command and config file
BINARYFILE=swiftlint
CONFIGFILE="${SRCROOT}/Configuration/swiftlint.yml"

WARNING="warning"
ERROR="error"

throw_not_found() {
  echo "$1: \"$2\" - not found. $3"
  if [ "$1" == "$WARNING" ]; then
    exit 0
  fi
  exit 1
}

display_usage() {
  echo "Usage:\n\nswiftlint.sh [arguments]\n"
  echo "Available arguments:"
  echo "  -h, --help\t\t\t# Show this output"
  echo "  -b, --binary=PATH_TO_BINARY\t# Path to Swiftlint binary file (default: swiftlint"
  echo "  -c, --config=PATH_TO_FILE\t# Path to Swiftlint configuration file (default: \${SRCROOT}/.swiftlint.yml)"
}

# Get arguments for binary and configuration file 
while [ "$#" -gt 0 ]; do
  case "$1" in
    -b) BINARYFILE="$2"; shift 2;;
    -c) CONFIGFILE="$2"; shift 2;;
    -h) display_usage; exit 0;;

    --binary=*) BINARYFILE="${1#*=}"; shift 1;;
    --config=*) CONFIGFILE="${1#*=}"; shift 1;;
    --help) display_usage; exit0;;
    --binary|--config) echo "$1 requires an argument" >&2; exit 1;;

    -*) echo "unknown option: $1" >&2; exit 1;;
    *) handle_argument "$1"; shift 1;;
  esac
done

# Check whether Swiftlint binary exists
if ! which $BINARYFILE &> /dev/null; then
  throw_not_found $WARNING $BINARYFILE "See https://github.com/realm/SwiftLint"
fi

# Check whether Swiftlint Config file exists
if [ ! -f "${CONFIGFILE}" ]; then
  throw_not_found $ERROR "${CONFIGFILE}" ""
fi 

# All hunky dory, run linting
$BINARYFILE --config "${CONFIGFILE}" --strict

# Finish the script
exit 0