#!/usr/bin/env bash

set -euo pipefail

echo "--- :rubygems: Setting up Gems"
install_gems

a8c_secrets_dir="$HOME/.local/bin"
install_a8c-secrets_binary --install-dir "$a8c_secrets_dir"
export PATH="$a8c_secrets_dir:$PATH"

package_resolved="Demo/Gravatar-Demo.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
restore_swiftpm_cache --package-resolved "$package_resolved"

echo "--- :hammer_and_wrench: Building Demo"
make build-demo-for-distribution

save_swiftpm_cache --package-resolved "$package_resolved"
