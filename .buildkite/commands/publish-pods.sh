#!/bin/bash -eu

if [ $# -eq 0 ]; then
    echo "Error: CocoaPods publishing failed. All podspecs must be specified, separated by spaces."
    exit 1
fi

SLACK_WEBHOOK=$PODS_SLACK_WEBHOOK
PODSPEC_PATHS=("$@")

# Verify that all versions are current before publishing any podspecs
echo "--- :cocoapods: Verify version of all podspecs"
invalid_pod=false
for podspec_path in "${PODSPEC_PATHS[@]}"; do
    pod_version=$(bundle exec pod ipc spec "$podspec_path" | jq -r '.version')
    if [ -n "$BUILDKITE_TAG" ] && [ "$BUILDKITE_TAG" != "$pod_version" ]; then
	    echo "Tag $BUILDKITE_TAG does not match version $pod_version from $podspec_path."
	    invalid_pod=true
    fi
done

if ( $invalid_pod ); then
    exit 1
fi

echo "--- :rubygems: Setting up Gems"
install_gems

for podspec_path in "${PODSPEC_PATHS[@]}"; do
    echo "--- :cocoapods: Publishing Pod to CocoaPods CDN"
    publish_pod $podspec_path

    echo "--- :slack: Notifying Slack"
    slack_notify_pod_published $podspec_path "$SLACK_WEBHOOK"
done
