#!/usr/bin/env bash

set -euo pipefail

# Materialize the demo app's Secrets.swift into DerivedData so the decrypted
# credentials never land in the repo checkout (AINFRA-2640).
#
# a8c-secrets decrypts to ~/.a8c-secrets/<repo-id>/; repo-id is read from the
# committed .a8c-secrets/repo-id so this path can't drift on casing. When the
# secret is absent — external contributors, or before provisioning lands — fall
# back to the committed template, whose nil/empty defaults still let the demo
# build.

REPO_ID_FILE="${SRCROOT}/../.a8c-secrets/repo-id"
TEMPLATE="${SRCROOT}/Demo/Secrets.tpl"
DESTINATION="${SCRIPT_OUTPUT_FILE_0}"

mkdir -p "$(dirname "$DESTINATION")"

if [ -f "$REPO_ID_FILE" ]; then
    repo_id="$(tr -d '[:space:]' < "$REPO_ID_FILE")"
    secrets_file="${HOME}/.a8c-secrets/${repo_id}/Secrets.swift"
    if [ -f "$secrets_file" ]; then
        echo "Applying demo secrets from ${secrets_file}"
        cp "$secrets_file" "$DESTINATION"
        exit 0
    fi
fi

echo "warning: demo secrets not found — building with the template fallback. Internal contributors: run 'bundle exec fastlane configure_secrets'."
cp "$TEMPLATE" "$DESTINATION"
