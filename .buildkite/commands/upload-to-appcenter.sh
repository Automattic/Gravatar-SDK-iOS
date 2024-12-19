#!/bin/bash -eu

echo "--- :arrow_down: Downloading Prototype Build"
buildkite-agent artifact download ".build/artifacts/*.ipa" . --step "build_demo"
buildkite-agent artifact download ".build/artifacts/*.app.dSYM.zip" . --step "build_demo"

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :hammer_and_wrench: Uploading"
bundle exec fastlane ios upload_demo_to_appcenter build_number:"$BUILDKITE_BUILD_NUMBER"
