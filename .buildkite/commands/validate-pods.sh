#!/bin/bash -eu

if [ $# -ne 1 ]; then
    echo "Error: CocoaPods validate podspec failed. Specify a path to a podspec."
    exit 1
fi

PODSPEC_PATH="$1"

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :microscope: Validate Podspec"
# For some reason this fixes a failure in `lib lint`
# https://github.com/Automattic/buildkite-ci/issues/7
xcrun simctl list >> /dev/null
bundle exec pod lib lint \
    --include-podspecs="$PODSPEC_PATH" \
    --verbose --fail-fast
