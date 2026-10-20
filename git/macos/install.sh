#!/usr/bin/env bash
# macOS entry for the git setup.
# Run through git/install.sh, or directly: ./git/macos/install.sh [--dry-run]

set -euo pipefail

GIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$GIT_DIR/common.sh" macos "$@"
