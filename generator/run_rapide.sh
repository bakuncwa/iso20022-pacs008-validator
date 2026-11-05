#!/usr/bin/env bash
# Build rapide at a pinned commit and generate N pacs.008 messages into data/raw/<run>/.
# Usage: run_rapide.sh <count> <run-id>
# rapide has no seed option: see qa/spec-gaps.md (GAP-1). Blob upload arrives in Phase 3.
set -euo pipefail

N="${1:?count required}"
RUN="${2:?run id required}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAPIDE_REPO=https://github.com/aws-samples/iso20022-message-generator.git
RAPIDE_REF=d96f648767dec26f0afdd3be0f0ca2b4eb15aaa8
RAPIDE_DIR="$ROOT/.cache/rapide"
OUT="$ROOT/data/raw/$RUN"

if [ ! -d "$RAPIDE_DIR/.git" ]; then
  git clone "$RAPIDE_REPO" "$RAPIDE_DIR"
fi
git -C "$RAPIDE_DIR" checkout --quiet "$RAPIDE_REF"

JAR_GLOB=("$RAPIDE_DIR"/pacs008/build/libs/*.jar)
if [ ! -e "${JAR_GLOB[0]}" ]; then
  (cd "$RAPIDE_DIR" && ./gradlew clean build -x test)
fi

mkdir -p "$OUT"
if [ -n "$(ls -A "$OUT")" ]; then
  echo "ERROR: $OUT is not empty. Use a new run id." >&2
  exit 1
fi
cp "$ROOT/generator/application.yaml" "$RAPIDE_DIR/pacs008/application.yaml"
(cd "$RAPIDE_DIR/pacs008" && ./rapide-iso20022 -n "$N" -d "$OUT" -o pacs008)

# rapide can skip messages and still exit 0, so the file count is the real check.
COUNT="$(find "$OUT" -type f | wc -l | tr -d ' ')"
if [ "$COUNT" -ne "$N" ]; then
  echo "ERROR: expected $N files, got $COUNT in $OUT" >&2
  exit 1
fi
echo "Generated $COUNT files in $OUT"
