#!/bin/bash -eu

# This scripts tries to replicate what `swift package diagnose-api-breaking-changes` does but for an iOS SDK
#
# I haven't found a way to do this with `swift package diagnose-api-breaking-changes` so I'm doing it manually
#
# Closest I've found is:
# ```
# swift package \
#   --sdk "$(xcrun --sdk iphoneos --show-sdk-path)" \
#   --triple arm64-apple-ios \
#   diagnose-api-breaking-changes 2.1.0
# ```
# but it doesn't work as well:
# - If I point to `2.1.0`, it generates errors during compilation about `type 'Bundle' has no member 'module'`. I think that might be because the swift-tools-version have changed since 2.1.0 though
# - If I point to `3.2.0-rc.1`, it succeeds to compile... but generates empty `.build//arm64-apple-ios/apidiff/*/*/json` files, which makes the `swift api-digester` command fail with "Unable to parse empty data."
#
# So I'm working around by doing the intermediate steps manually compiling with `xcodebuild` then using `swift api-digester` instead.


# Prints a blue header (level 1)
function h1() {
  printf '\033[1;34m======================================================\033[0m\n'
  printf '\033[1;34m| %-50s |\033[0m\n' "$1"
  printf '\033[1;34m======================================================\033[0m\n'
}

# Prints a blue header (level 2)
function h2() {
  printf '\033[1;34m------------------------------------------------------\033[0m\n'
  printf '\033[1;34m%s\033[0m\n' "$1"
  printf '\033[1;34m------------------------------------------------------\033[0m\n'
}

# Build the SDK (from current branch) in .build/
#
function build_sdk() {
  h2 "Building SDK"
  xcodebuild clean build \
      -scheme "Gravatar-Package" \
      -derivedDataPath .build \
      -sdk "$(xcrun --sdk iphoneos --show-sdk-path)" \
      -destination "generic/platform=iOS" \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty
}

# Use api-digester to dump the SDK API to a JSON file
#
# $1: output file
#
function dump_sdk_api() {
  h2 "Dumping SDK API"
  swift api-digester -dump-sdk \
    -module Gravatar \
    -o "$1" \
    -I .build/Build/Products/Debug-iphoneos \
    -sdk "`xcrun --sdk iphoneos --show-sdk-path`" \
    -target "arm64-apple-ios"
  echo "==> Generated API JSON to $1"
}

# Generate the API JSON for a given branch/treeish
#
# Checks out the branch, then calls `build_sdk`, then `dump_sdk_api`
#
# $1: branch/treeish to build + dump the API for
#
function generate_api_for_branch() {
  h1 "Generating API JSON for $1"
  git checkout "$1"
  build_sdk
  dump_sdk_api ".build/api-${1/\//-}.json"
}

# Compare the API of two branches/treeishs
#
# Calls `generate_api_for_branch` for both branches, then `swift api-digester` to compare the APIs
#
# $1: old branch/treeish to compare against
# $2: new branch/treeish to compare against, or current branch if not provided
#
function compare_api() {
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  local old_branch="$1"
  local new_branch="${2:-$current_branch}"
  
  generate_api_for_branch "$old_branch"
  git restore Package.resolved
  generate_api_for_branch "$new_branch"
  
  git checkout "$current_branch"

  h1 "Diagnosing API differences"
  swift api-digester -diagnose-sdk \
    --input-paths ".build/api-${old_branch/\//-}.json" \
    --input-paths ".build/api-${new_branch/\//-}.json" \
    2>&1 | sed $'s|^/\\*.*\\*/|\x1b[1;33m&\x1b[0m|' # the use of `sed` is to colorize the diff output
}

compare_api "$@"
