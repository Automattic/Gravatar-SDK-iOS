#!/bin/bash -eu

echo "--- :cocoapods: Validate Gravatar.podspec"
validate_podspec Gravatar.podspec

echo "--- :cocoapods: Validate GravatarUI.podspec"
validate_podspec GravatarUI.podspec
