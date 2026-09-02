#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

REPO_NAME="${REPO_NAME:-RippleLoop}"
VISIBILITY="${VISIBILITY:-public}"
GITHUB_OWNER="${GITHUB_OWNER:-}"
DESCRIPTION="Ripple Run — meditative endless stone-skipping iPhone game"

if [ -n "${GH_TOKEN:-}" ]; then
  export GH_TOKEN
elif [ -n "${GITHUB_TOKEN:-}" ]; then
  export GH_TOKEN="$GITHUB_TOKEN"
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install: https://cli.github.com/"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  if [ -n "${GH_TOKEN:-}" ]; then
    printf '%s\n' "$GH_TOKEN" | gh auth login --with-token
  else
    echo "GitHub CLI is not authenticated."
    echo "Add GH_TOKEN to Cursor Cloud Agent secrets, then start a new agent run."
    exit 1
  fi
fi

if [ -z "$GITHUB_OWNER" ]; then
  GITHUB_OWNER="$(gh api user -q .login)"
fi

FULL_REPO="$GITHUB_OWNER/$REPO_NAME"
REMOTE_URL="https://github.com/$FULL_REPO.git"
AUTH_REMOTE="https://x-access-token:${GH_TOKEN}@github.com/$FULL_REPO.git"

echo "GitHub user: $GITHUB_OWNER"
echo "Repository:  $FULL_REPO"

if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  echo "Repository already exists."
else
  echo "Creating repository..."
  if [ "$VISIBILITY" = "private" ]; then
    gh repo create "$REPO_NAME" \
      --description "$DESCRIPTION" \
      --private
  else
    gh repo create "$REPO_NAME" \
      --description "$DESCRIPTION" \
      --public
  fi
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [ -n "${GH_TOKEN:-}" ]; then
  git push "https://x-access-token:${GH_TOKEN}@github.com/$FULL_REPO.git" "$CURRENT_BRANCH:refs/heads/$CURRENT_BRANCH"
  git branch --set-upstream-to="origin/$CURRENT_BRANCH" "$CURRENT_BRANCH" 2>/dev/null || true
else
  git push -u origin "$CURRENT_BRANCH"
fi

echo ""
echo "Done: https://github.com/$FULL_REPO"
