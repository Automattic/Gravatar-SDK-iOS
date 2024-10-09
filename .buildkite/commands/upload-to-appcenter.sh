#!/bin/bash -eu

NAME=$1
NAME_LOWERCASED="$(echo "$NAME" | tr '[:upper:]' '[:lower:]')"

echo "--- :arrow_down: Downloading Prototype Build"
buildkite-agent artifact download ".build/artifacts/*.ipa" . --step "build_$NAME_LOWERCASED"
buildkite-agent artifact download ".build/artifacts/*.app.dSYM.zip" . --step "build_$NAME_LOWERCASED"

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :hammer_and_wrench: Uploading"
bundle exec fastlane ios upload_demo_to_appcenter name:"$NAME" build_number:"$BUILDKITE_BUILD_NUMBER"
