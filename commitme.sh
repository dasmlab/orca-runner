
#!/bin/bash
set -euo pipefail
trap 'echo "Script failed at line $LINENO: $BASH_COMMAND"' ERR

BUMP_TYPE="$1"
shift
MSG="$*"

if [[ -z "$BUMP_TYPE" || -z "$MSG" ]]; then
  echo "Usage: ./commitme.sh [point|minor|major] \"tag message\""
  exit 1
fi

echo "Pulling latest from origin/$(git rev-parse --abbrev-ref HEAD)..."
if git rev-parse HEAD >/dev/null 2>&1; then
  git pull origin "$(git rev-parse --abbrev-ref HEAD)" --tags 2>/dev/null || true
else
  echo "No commits yet — skipping pull."
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$' | sort -V | tail -n 1 || true)

if [[ -z "$LATEST_TAG" ]]; then
  MAJOR=0
  MINOR=0
  PATCH=0
  SUFFIX="-alpha"
else
  VERSION=$(echo "$LATEST_TAG" | cut -d '-' -f1)
  SUFFIX=$(echo "$LATEST_TAG" | grep -oE '\-[a-zA-Z0-9]+$' || echo "-alpha")

  MAJOR=$(echo "$VERSION" | cut -d. -f1 | sed 's/^0*//')
  MINOR=$(echo "$VERSION" | cut -d. -f2 | sed 's/^0*//')
  PATCH=$(echo "$VERSION" | cut -d. -f3 | sed 's/^0*//')

  MAJOR=${MAJOR:-0}
  MINOR=${MINOR:-0}
  PATCH=${PATCH:-0}
fi

echo "Current version: $MAJOR.$MINOR.$PATCH$SUFFIX"

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  point)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Invalid bump type: $BUMP_TYPE"
    exit 1
    ;;
esac

NEW_TAG="${MAJOR}.${MINOR}.${PATCH}${SUFFIX}"
echo "New version: $NEW_TAG"

git add -A .
if git diff --cached --quiet; then
  echo "No staged changes. Aborting."
  exit 1
fi

git commit -m "$MSG"
git tag -a "$NEW_TAG" -m "$MSG"
git push origin "$BRANCH"
git push origin "$NEW_TAG"

echo "Done: $NEW_TAG pushed to $BRANCH"
