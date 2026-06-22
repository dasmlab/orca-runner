#!/usr/bin/env bash
# Tier 2 — Full 5G + E2 lab (Open5GS + srsRAN gNB + srsUE + RIC)
# Prerequisite: Tier 1 RIC up (./labs/setup-oran-sc-ric-lab.sh up)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="${ROOT}/labs/oran-sc-ric"
# Use vigie clone if public repo lab dir not present
if [[ ! -d "${LAB_DIR}" && -d "/home/dasm/vigie/orca-runner/labs/oran-sc-ric" ]]; then
  LAB_DIR="/home/dasm/vigie/orca-runner/labs/oran-sc-ric"
fi
SRS_PROJECT_DIR="${ROOT}/labs/srsRAN_Project"
SRS_4G_DIR="${ROOT}/labs/srsRAN_4G"
GNB_CFG="${ROOT}/labs/configs/gnb_zmq_tier2.yaml"
UE_CFG="${LAB_DIR}/e2-agents/srsRAN/ue_zmq.conf"
LOG_DIR="${ROOT}/labs/tier2-logs"
mkdir -p "${LOG_DIR}"

cmd="${1:-}"

clone_repos() {
  if [[ ! -d "${SRS_PROJECT_DIR}/.git" ]]; then
    echo "Cloning srsRAN_Project (release_24_10 branch)..."
    git clone --depth 1 --branch release_24_10 https://github.com/srsran/srsRAN_Project.git "${SRS_PROJECT_DIR}"
  fi
  if [[ ! -d "${SRS_4G_DIR}/.git" ]]; then
    echo "Cloning srsRAN_4G..."
    git clone --depth 1 https://github.com/srsran/srsRAN_4G.git "${SRS_4G_DIR}"
  fi
}

build_srsran_project() {
  clone_repos
  export PATH="${HOME}/.local/cmake/bin:${PATH}"
  local gnb_bin="${SRS_PROJECT_DIR}/build/apps/gnb/gnb"
  if [[ -x "${gnb_bin}" ]]; then
    if timeout 3s "${gnb_bin}" -c "${GNB_CFG}" 2>&1 | grep -q "INI was not able to parse"; then
      echo "gnb binary exists but config failed — rebuild after deps/config fix"
    else
      echo "gnb already built and config parses"
      return
    fi
  fi
  if ! pkg-config --exists mbedtls 2>/dev/null; then
    echo "Missing build deps. Run: ./labs/install-tier2-deps.sh" >&2
    exit 1
  fi
  echo "Building srsRAN_Project (this takes several minutes)..."
  cmake -B "${SRS_PROJECT_DIR}/build" -S "${SRS_PROJECT_DIR}" \
    -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON -DENABLE_DPDK=OFF -DENABLE_UHD=OFF
  cmake --build "${SRS_PROJECT_DIR}/build" -j"$(nproc)" --target gnb
}

build_srsran_4g_ue() {
  clone_repos
  export PATH="${HOME}/.local/cmake/bin:${PATH}"
  if [[ -x "${SRS_4G_DIR}/build/srsue/src/srsue" ]]; then
    echo "srsue already built"
    return
  fi
  if ! pkg-config --exists mbedtls 2>/dev/null || [[ ! -f /usr/include/boost/version.hpp ]]; then
    echo "Missing build deps (Boost/MbedTLS). Run: ./labs/install-tier2-deps.sh" >&2
    exit 1
  fi
  echo "Building srsRAN_4G srsue (UE only)..."
  cmake -B "${SRS_4G_DIR}/build" -S "${SRS_4G_DIR}" \
    -DENABLE_ZEROMQ=ON \
    -DENABLE_UHD=OFF \
    -DENABLE_SRSENB=OFF \
    -DENABLE_SRSEPC=OFF \
    -DENABLE_GUI=OFF \
    -DENABLE_RF_PLUGINS=OFF \
    -DENABLE_BLADERF=OFF \
    -DENABLE_SOAPYSDR=OFF
  cmake --build "${SRS_4G_DIR}/build" -j"$(nproc)" --target srsue
}

setup_host_ric_route() {
  docker network inspect oran-sc-ric_ric_network >/dev/null 2>&1 || {
    echo "RIC network not found. Run ./labs/setup-oran-sc-ric-lab.sh up first." >&2
    exit 1
  }
}

start_5gc() {
  clone_repos
  setup_host_ric_route
  cd "${SRS_PROJECT_DIR}/docker"
  docker compose up -d 5gc
  echo "5GC starting — wait ~30s for AMF ready"
}

start_gnb() {
  build_srsran_project
  [[ -f "${LAB_DIR}/.env" ]] || { echo "RIC lab missing"; exit 1; }
  mkdir -p "${LOG_DIR}"
  # Stale /tmp/gnb.log from older configs blocks sudo runs
  sudo rm -f /tmp/gnb.log 2>/dev/null || true
  pkill -f 'build/apps/gnb/gnb' 2>/dev/null || true
  sleep 2
  echo "Starting gNB (no sudo needed for ZMQ) — tee log: ${LOG_DIR}/gnb-console.log"
  echo "Wait for: E2 Setup procedure successful + ==== gNB started ==="
  "${SRS_PROJECT_DIR}/build/apps/gnb/gnb" -c "${GNB_CFG}" 2>&1 | tee "${LOG_DIR}/gnb-console.log"
}

start_ue() {
  build_srsran_4g_ue
  sudo ip netns del ue1 2>/dev/null || true
  sudo ip netns add ue1
  echo "Starting srsUE — logs: ${LOG_DIR}/ue.log"
  sudo "${SRS_4G_DIR}/build/srsue/src/srsue" "${UE_CFG}" 2>&1 | tee "${LOG_DIR}/ue.log"
}

check_e2() {
  local json
  json=$(curl -sf "http://10.0.2.11:3800/v1/e2t/list" 2>/dev/null || true)
  if [[ -z "${json}" ]]; then
    echo "E2 check: e2mgr API unreachable at 10.0.2.11:3800"
    return 1
  fi
  echo "E2 nodes registered: ${json}"
  if echo "${json}" | grep -q '"ranNames":\[\]'; then
    return 1
  fi
  if echo "${json}" | grep -q 'gnbd_'; then
    return 0
  fi
  # non-empty ranNames but unexpected id — still try
  echo "${json}" | grep -q '"ranNames":\[.\+' && return 0
  return 1
}

wait_for_e2() {
  local i max=24
  echo "Waiting for E2 node in RIC (up to 120s)..."
  for ((i=1; i<=max; i++)); do
    if check_e2; then
      echo "E2 ready."
      return 0
    fi
    sleep 5
  done
  echo "E2 NOT registered. Common causes:" >&2
  echo "  - gNB log: 'E2 Setup procedure failed' (RIC 60s reconnect — restart RIC or wait)" >&2
  echo "  - gNB not running in terminal A" >&2
  echo "  Fix: ./labs/setup-oran-sc-ric-lab.sh down && up ; wait 60s ; restart gNB once" >&2
  return 1
}

xapp_kpm_smoke() {
  cd "${LAB_DIR}"
  if ! wait_for_e2; then
    echo "Skipping xApp — no E2 node. UE can work while E2 is down; KPM cannot." >&2
    return 1
  fi
  echo "Starting KPM xApp (45s timeout)..."
  timeout 45s docker compose exec -T python_xapp_runner \
    ./simple_mon_xapp.py --metrics=DRB.UEThpDl,DRB.UEThpUl 2>&1 | tee "${LOG_DIR}/xapp-mon.log" || true
  echo "--- submgr (last 3 lines) ---"
  docker compose logs submgr --tail=3 2>/dev/null || true
}

status() {
  echo "=== RIC ==="
  docker compose -f "${LAB_DIR}/docker-compose.yml" ps 2>/dev/null || true
  echo "=== 5GC ==="
  docker compose -f "${SRS_PROJECT_DIR}/docker/docker-compose.yml" ps 2>/dev/null || echo "5GC not started"
  echo "=== Builds ==="
  [[ -x "${SRS_PROJECT_DIR}/build/apps/gnb/gnb" ]] && echo "gnb: ok" || echo "gnb: not built"
  [[ -x "${SRS_4G_DIR}/build/srsue/src/srsue" ]] && echo "srsue: ok" || echo "srsue: not built"
  echo "=== E2 (e2mgr) ==="
  check_e2 || true
  docker compose -f "${LAB_DIR}/docker-compose.yml" logs submgr --tail=3 2>/dev/null || true
  if [[ -f "${LOG_DIR}/gnb-srs.log" ]]; then
    echo "=== gNB E2 (last) ==="
    grep -E 'E2 Setup|E2setup' "${LOG_DIR}/gnb-srs.log" 2>/dev/null | tail -3 || true
  fi
}

case "${cmd}" in
  clone) clone_repos ;;
  build) build_srsran_project && build_srsran_4g_ue ;;
  5gc) start_5gc ;;
  gnb) start_gnb ;;
  ue) start_ue ;;
  xapp) xapp_kpm_smoke ;;
  check-e2) check_e2 ;;
  wait-e2) wait_for_e2 ;;
  status) status ;;
  *)
    cat <<EOF
Usage: $0 {clone|build|5gc|gnb|ue|xapp|check-e2|wait-e2|status}

Typical Tier 2 flow (multiple terminals):
  1. ./labs/setup-oran-sc-ric-lab.sh up
  2. $0 clone && $0 build
  3. $0 5gc
  4. $0 gnb          # terminal A (sudo, foreground)
  5. $0 ue           # terminal B (sudo, foreground)
  6. $0 xapp         # KPM smoke test

Logs: ${LOG_DIR}/
Guide: docs/labs/02-tier2-ran-guide.md
EOF
    exit 1
    ;;
esac
