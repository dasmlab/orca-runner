# Tier 2 — connected lab validation log

**Goal:** ≥1 successful KPM `RIC_INDICATION` with gNB + UE attached.

| Field | Value |
|-------|-------|
| **RIC lab commit** | `621ade2` |
| **Date** | 2026-06-22 |
| **Host** | vigie dev host |

---

## Setup status

| Step | Status | Notes |
|------|--------|-------|
| Tier 1 RIC Up | ✅ | 7/7 containers |
| Clone srsRAN_Project | ✅ | `release_24_10` in `labs/srsRAN_Project` |
| Clone srsRAN_4G | ✅ | `labs/srsRAN_4G` |
| Build gNB | ⬜ blocked | Needs `libmbedtls-dev` + cmake deps (`sudo apt`) |
| Build srsUE | ⬜ blocked | Same |
| Open5GS `5gc` docker | ✅ | `open5gs_5gc` healthy (2026-06-22) |
| gNB connected to RIC | ⬜ | requires **sudo** on host |
| srsUE attached | ⬜ | requires **sudo** + netns |
| KPM `RIC_INDICATION` | ⬜ | |
| Connected sample report | ⬜ | `docs/samples/srsran-lab-connected-report.json` |

---

## Blockers encountered (2026-06-22)

### Build dependencies (srsRAN_4G / Boost)

```
CMake Error: Boost required to build srsRAN
```

**Fix:**

```bash
./labs/install-tier2-deps.sh
./labs/setup-tier2-ran-lab.sh build
```

SoapySDR / UHD not found — **safe to ignore** for ZMQ lab.

### gNB config drift (oran-sc-ric)

Upstream `gnb_zmq.yaml` fails on srsRAN `release_24_10`:

```
INI was not able to parse gnb_cu_up_id
```

**Fix:** use [`labs/configs/gnb_zmq_tier2.yaml`](../../configs/gnb_zmq_tier2.yaml) (committed in orca-runner).

### sudo required

gNB and srsUE must run as root (`sudo`). Non-interactive agent sessions cannot complete Tier 2 without passwordless sudo or a human terminal.

**Fix:** on the host, in separate terminals:

```bash
./labs/setup-tier2-ran-lab.sh gnb   # terminal A
./labs/setup-tier2-ran-lab.sh ue    # terminal B
```

---

## 5GC

```bash
cd labs/srsRAN_Project/docker && docker compose up -d 5gc
docker ps --filter name=open5gs_5gc
# open5gs_5gc — Up (healthy)
```

Network: `docker_ran` (AMF at `10.53.1.2` per gnb_zmq.yaml).

---

## E2 connection evidence

<!-- Paste submgr / gnb log lines when gNB connects -->

Expected when working:

```
E2 setup successful
No E2 connection for ranName ...  # should STOP after gNB connects
RIC Indication Received from gnbd_001_001_00019b_0
```

---

## xApp KPM run

<!-- Fill after ./labs/setup-tier2-ran-lab.sh xapp -->

---

## orca-runner scan (connected)

<!-- Compare to srsran-lab-warn-report.json -->
