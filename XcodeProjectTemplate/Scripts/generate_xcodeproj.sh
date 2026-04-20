#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is not installed. Install with: brew install xcodegen"
  exit 1
fi

xcodegen generate

echo "✅ Generated OpenF1Dashboard.xcodeproj"
echo "Next: open OpenF1Dashboard.xcodeproj"
