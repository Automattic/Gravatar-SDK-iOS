#!/usr/bin/env bash

set -euo pipefail

# Materialize the demo app's Secrets.swift into DerivedData so the decrypted
# credentials never land in the repo checkout (AINFRA-2640). Source, in order:
#
#   1. ~/.a8c-secrets/<repo-id>/Secrets.swift — internal contributors, decrypted
#      by a8c-secrets outside the repo. repo-id is read from the committed
#      .a8c-secrets/repo-id so the path can't drift on casing.
#   2. Demo/Demo/Secrets.external-contributors.swift — seeded from the template on
#      first build and gitignored, so external contributors can paste their own
#      credentials into a clearly named file that can't be committed.
#   3. Demo/Demo/Secrets.template.swift — committed template with nil/empty
#      defaults, so the demo always builds without any secrets.

REPO_ID_FILE="${SRCROOT}/../.a8c-secrets/repo-id"
TEMPLATE="${SRCROOT}/Demo/Secrets.template.swift"
EXTERNAL="${SRCROOT}/Demo/Secrets.external-contributors.swift"
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

# The a8c-secrets file is absent — warn every time, even when a fallback exists,
# so internal contributors notice a missing/undecrypted secret.
echo "warning: decrypted demo secrets not found under ~/.a8c-secrets. Internal contributors: run 'bundle exec fastlane configure_secrets'."

# Seed the external-contributors file from the template on first build. It is
# gitignored, so edits persist across builds and can't be committed.
if [ ! -f "$EXTERNAL" ]; then
    echo "Seeding ${EXTERNAL} from the template — external contributors: add your own credentials there."
    cp "$TEMPLATE" "$EXTERNAL"
fi

cp "$EXTERNAL" "$DESTINATION"
