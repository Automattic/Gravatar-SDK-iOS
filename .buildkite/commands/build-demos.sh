#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- Generate Secrets.swift source file"
make secrets

echo "--- 🛠 Building Demo (Swift)"
bundle exec fastlane build_demo scheme:Gravatar-Demo

echo "--- 🛠 Building Demo (SwiftUI)"
bundle exec fastlane build_demo scheme:Gravatar-SwiftUI-Demo
