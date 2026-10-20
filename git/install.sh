#!/usr/bin/env bash
# Entrypoint: detects the OS and hands over to git/<os>/install.sh.
#
# Usage: ./git/install.sh [--dry-run]

set -euo pipefail

GIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Linux)  OS=linux ;;
  Darwin) OS=macos ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

exec "$GIT_DIR/$OS/install.sh" "$@"
