#!/usr/bin/env bash
# Linux entry for the git setup.
# Run through git/install.sh, or directly: ./git/linux/install.sh [--dry-run]

set -euo pipefail

GIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$GIT_DIR/common.sh" linux "$@"
