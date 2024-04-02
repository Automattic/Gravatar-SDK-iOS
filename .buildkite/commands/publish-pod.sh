#!/bin/bash -eu

if [ $# -ne 1 ]; then
    echo "Error: CocoaPods publishing failed. Specify a path to a podspec."
    exit 1
fi

SLACK_WEBHOOK=$PODS_SLACK_WEBHOOK
PODSPEC_PATH="$1"

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Publishing Pod to CocoaPods CDN"
publish_pod "$PODSPEC_PATH"

echo "--- :slack: Notifying Slack"
slack_notify_pod_published "$PODSPEC_PATH" "$SLACK_WEBHOOK"
