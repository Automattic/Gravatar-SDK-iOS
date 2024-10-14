#!/bin/bash -eu

echo "--- :cocoapods: Validate Gravatar.podspec"
validate_podspec --allow-warnings Gravatar.podspec

echo "--- :cocoapods: Validate GravatarUI.podspec"
validate_podspec --allow-warnings GravatarUI.podspec

echo "--- :cocoapods: Validate GravatarOpenAPIClient.podspec"
validate_podspec --allow-warnings GravatarOpenAPIClient.podspec
