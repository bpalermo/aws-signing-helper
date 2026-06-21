#!/usr/bin/env bash
# Workspace status script for Bazel stamping.
# Provides Git metadata for container image tags.
set -euo pipefail

echo "STABLE_GIT_COMMIT $(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
echo "GIT_COMMIT_SHORT $(git rev-parse --short=7 HEAD 2>/dev/null || echo 'unknown')"
echo "GIT_BRANCH $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
