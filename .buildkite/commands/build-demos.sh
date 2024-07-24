#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- 🛠 Building Demo (Swift)"
bundle exec fastlane build_demo scheme:Swift-Demo

echo "--- 🛠 Building Demo (SwiftUI)"
bundle exec fastlane build_demo scheme:SwiftUI-Demo
