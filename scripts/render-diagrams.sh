#!/usr/bin/env bash
# Render all .d2 diagrams to diagrams/svg/*.svg
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT}/diagrams"
OUT_DIR="${SRC_DIR}/svg"

if ! command -v d2 >/dev/null 2>&1; then
  if [[ -x "${HOME}/.local/bin/d2" ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
  else
    echo "d2 not found. Install: curl -fsSL https://d2lang.com/install.sh | sh -s --" >&2
    exit 1
  fi
fi

mkdir -p "${OUT_DIR}"
shopt -s nullglob
for src in "${SRC_DIR}"/*.d2; do
  base="$(basename "${src}" .d2)"
  echo "d2 ${base}.d2 -> svg/${base}.svg"
  d2 --layout=dagre "${src}" "${OUT_DIR}/${base}.svg"
done

echo "Done."
