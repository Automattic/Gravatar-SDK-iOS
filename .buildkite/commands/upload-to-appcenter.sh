#!/bin/bash -eu

NAME=$1
NAME_LOWERCASED="$(echo "$NAME" | tr '[:upper:]' '[:lower:]')"

iecho "--- :arrow_down: Downloading Prototype Build"
# TODO: remove build once verified
buildkite-agent artifact download ".build/artifacts/*.ipa" . --step "build_$NAME_LOWERCASED" --build "0190ee1c-6984-4fed-a59a-02f561c5ed2d"
buildkite-agent artifact download ".build/artifacts/*.app.dSYM.zip" . --step "build_$NAME_LOWERCASED" --build "0190ee1c-6984-4fed-a59a-02f561c5ed2d"

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :hammer_and_wrench: Uploading"
bundle exec fastlane upload_demo_to_appcenter "$NAME"
