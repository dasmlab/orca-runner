#!/usr/bin/env bash
# Setup and operate srsRAN oran-sc-ric lab for orca-runner integration.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="${ROOT}/labs/oran-sc-ric"
REPO="https://github.com/srsran/oran-sc-ric.git"
ORCA_BIN="${ROOT}/bin/orca-runner"
POLICY="${ROOT}/policies/oran-xapp-srsran-lab.yaml"

cmd="${1:-}"

clone_if_needed() {
  if [[ -d "${LAB_DIR}/.git" ]]; then
    echo "lab already cloned: ${LAB_DIR}"
    return
  fi
  git clone --depth 1 "${REPO}" "${LAB_DIR}"
}

build_orca() {
  make -C "${ROOT}" build
}

case "${cmd}" in
  up)
    clone_if_needed
    cd "${LAB_DIR}"
    docker compose pull || true
    docker compose build
    docker compose up -d
    echo "RIC up. Run: $0 status"
    ;;
  down)
    cd "${LAB_DIR}" && docker compose down
    ;;
  status)
    cd "${LAB_DIR}" && docker compose ps
    ;;
  logs)
    cd "${LAB_DIR}" && docker compose logs --tail=30 "${2:-}"
    ;;
  scan)
    build_orca
    "${ORCA_BIN}" check --policy "${POLICY}" "${LAB_DIR}"
    ;;
  scan-generic)
    build_orca
    "${ORCA_BIN}" check --policy "${ROOT}/policies/oran-xapp-v0.yaml" "${LAB_DIR}/xApps/python"
    ;;
  xapp-smoke)
    cd "${LAB_DIR}"
    docker compose exec -T python_xapp_runner ./simple_mon_xapp.py --metrics=DRB.UEThpDl
    ;;
  *)
    echo "Usage: $0 {up|down|status|logs [service]|scan|scan-generic|xapp-smoke}"
    exit 1
    ;;
esac
