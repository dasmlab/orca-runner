#!/usr/bin/env bash
# Check status of srsran/oran-sc-ric papercut PR #88
set -euo pipefail

PR=88
REPO=srsran/oran-sc-ric

if [[ -f "${HOME}/gh-pat" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/gh-pat"
fi

if ! command -v gh >/dev/null 2>&1; then
  GH="${GH:-/tmp/gh_2.65.0_linux_amd64/bin/gh}"
else
  GH=gh
fi

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "Not authenticated. Set GH_TOKEN or source ~/gh-pat" >&2
  exit 1
fi

"$GH" pr view "$PR" --repo "$REPO" \
  --json number,title,state,merged,mergedAt,mergedBy,url,reviewDecision \
  --jq '"PR #\(.number): \(.title)
State: \(.state)\(if .merged then " (merged \(.mergedAt) by \(.mergedBy.login))" else "" end)
Reviews: \(.reviewDecision // "none")
URL: \(.url)"'
