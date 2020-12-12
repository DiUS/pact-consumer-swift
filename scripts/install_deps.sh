#!/bin/bash
set -e

brew update && brew bundle
carthage checkout
