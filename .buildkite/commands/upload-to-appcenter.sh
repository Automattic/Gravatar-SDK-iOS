#!/bin/bash -eu

NAME=$1
NAME_LOWERCASED="$(echo "$NAME" | tr '[:upper:]' '[:lower:]')"

echo "--- :arrow_down: Downloading Prototype Build"
# TODO: remove build once verified
buildkite-agent artifact download ".build/artifacts/*.ipa" . --step "build_$NAME_LOWERCASED" --build "0190ee15-44cf-41ad-8132-7698c8a6db37"
buildkite-agent artifact download ".build/artifacts/*.app.dSYM.zip" . --step "build_$NAME_LOWERCASED" --build "0190ee15-44cf-41ad-8132-7698c8a6db37"

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :hammer_and_wrench: Uploading"
bundle exec fastlane ios upload_demo_to_appcenter name:"$NAME"
