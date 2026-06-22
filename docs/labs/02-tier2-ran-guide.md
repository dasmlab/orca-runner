# Tier 2 — Full 5G + E2 (live KPM)

**Goal:** Connect srsRAN gNB + UE to the docker RIC and receive at least one `RIC_INDICATION` — for **orca-runner credibility**, not srsRAN adoption.

See [03-ecosystem-reality.md](../roadmap/03-ecosystem-reality.md) for why srsRAN is a lab rat, not the main market.

**Prerequisite:** [Tier 1 guide](./01-oran-sc-ric-lab-guide.md) — RIC containers Up.

---

## What Tier 2 adds

```
Open5GS (5GC)  ←→  srsRAN gNB (E2 agent)  ←→  O-RAN SC RIC (docker)
                         ↕ ZMQ
                      srsUE
                         ↓
                   xApp KPM subscribe → RIC_INDICATION
```

---

## Host requirements

| Requirement | Notes |
|-------------|-------|
| Docker + Compose | Tier 1 + `5gc` service |
| **sudo** | gNB, srsUE, `ip netns` |
| Build toolchain | cmake, g++, libmbedtls-dev, libfftw3-dev, libsctp-dev, libzmq3-dev, … |
| Disk | ~2GB for clones + builds |
| Time | First build: 15–45 min |

### One-time deps (Ubuntu)

```bash
./labs/install-tier2-deps.sh
```

Or manually:

```bash
sudo apt-get install -y cmake git libfftw3-dev libmbedtls-dev libsctp-dev \
  libyaml-cpp-dev libgtest-dev libzmq3-dev libboost-program-options-dev libboost-dev
```

**Note:** SoapySDR / UHD warnings are OK for ZMQ-only lab (`-DENABLE_UHD=OFF`).

### gNB config

Use **`labs/configs/gnb_zmq_tier2.yaml`** — upstream `oran-sc-ric` `gnb_zmq.yaml` is **stale** for srsRAN `release_24_10` (`gnb_cu_up_id` parse error). Verified: E2 connects to `10.0.2.10:36421`.

---

## Scripted flow

**Order matters.** Do not start C until A shows E2 setup and B has an IP.

```bash
# Terminal 0 — RIC + 5GC (once)
./labs/setup-oran-sc-ric-lab.sh up
./labs/setup-tier2-ran-lab.sh 5gc

# Terminal A — gNB (leave running; no sudo for ZMQ)
./labs/setup-tier2-ran-lab.sh gnb
# Wait for: "E2 Setup procedure successful" and "==== gNB started ==="

# Terminal B — UE (sudo for netns; leave running)
./labs/setup-tier2-ran-lab.sh ue
# Wait for: "RRC Connected" and IP e.g. 10.45.1.2

# Terminal C — KPM xApp (after A + B stable)
./labs/setup-tier2-ran-lab.sh xapp
```

**Common pitfall:** `sudo ./gnb` fails if `/tmp/gnb.log` exists from a prior run — config now logs to `labs/tier2-logs/gnb-srs.log` instead.

Logs: `labs/tier2-logs/`

Validation log: [validation/03-tier2-connected.md](./validation/03-tier2-connected.md)

---

## E2 gotchas

- RIC **60s reconnect wait** after gNB disconnect
- Use `--e2_node_id gnbd_001_001_00019b_0`
- gNB `e2.bind_addr: 10.0.2.1` must reach docker `ric_network` gateway
- `rmr_flags` KPM vs RC tradeoff ([#12](https://github.com/srsran/oran-sc-ric/issues/12))

Configs: `labs/oran-sc-ric/e2-agents/srsRAN/`

---

## orca-runner after Tier 2

```bash
./labs/setup-oran-sc-ric-lab.sh scan
# Commit sample: docs/samples/srsran-lab-connected-report.json
```

Compare clone-only warn report vs connected lab.

---

## Known blockers on automated CI hosts

- **sudo** required for gNB/UE — not available in all agent environments
- **srsRAN_Project** archived — still used by oran-sc-ric README; OCUDU may replace long-term
