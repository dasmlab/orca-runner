# srsRAN oran-sc-ric — Local Lab Guide

**Goal:** Run the dockerized Near-RT RIC, develop xApps, and validate orca-runner scans before proposing upstream CI.

**Upstream:** [github.com/srsran/oran-sc-ric](https://github.com/srsran/oran-sc-ric)  
**Wrapper script:** [`labs/setup-oran-sc-ric-lab.sh`](../labs/setup-oran-sc-ric-lab.sh)

---

## Tiers

| Tier | What runs | Purpose |
|------|-----------|---------|
| **Tier 1 — RIC only** | Docker compose (7 containers) | orca-runner integration, xApp dev loop |
| **Tier 2 — Full RAN** | Tier 1 + Open5GS + srsRAN gNB + srsUE | Live E2/KPM indications |

Start with **Tier 1**.

---

## Tier 1 — RIC platform

### Prerequisites

| Requirement | Notes |
|-------------|-------|
| Docker + Compose v2 | `docker compose` |
| Git | Lab clone via setup script |
| ~4GB disk | O-RAN SC images from `nexus3.o-ran-sc.org` |

### Commands

```bash
git clone https://github.com/dasmlab/orca-runner.git
cd orca-runner
./labs/setup-oran-sc-ric-lab.sh up
./labs/setup-oran-sc-ric-lab.sh status
```

Expected containers:

| Container | Role |
|-----------|------|
| ric_e2term | E2 termination (SCTP) |
| ric_e2mgr | E2 manager |
| ric_dbaas | Redis/SDL |
| ric_submgr | Subscription manager |
| ric_appmgr | xApp manager |
| ric_rtmgr_sim | Routing manager simulator |
| python_xapp_runner | xApp dev container |

Two images are built locally: `rtmgr_sim:i-release`, `python_xapp_runner:i-release`.

### xApp without gNB

```bash
./labs/setup-oran-sc-ric-lab.sh xapp-smoke
```

Without a connected E2 agent, subscription fails at SubMgr — **expected**. Tier 2 is needed for live KPM.

### Teardown

```bash
./labs/setup-oran-sc-ric-lab.sh down
```

---

## orca-runner on this lab

```bash
./labs/setup-oran-sc-ric-lab.sh scan
```

Policy: [`policies/oran-xapp-srsran-lab.yaml`](../policies/oran-xapp-srsran-lab.yaml)

Typical **WARN** findings (see [samples/srsran-lab-warn-report.json](../samples/srsran-lab-warn-report.json)):

| Finding | Threat class |
|---------|--------------|
| README E2 ID examples use `gnb_*` | T-E2 |
| `rmr_flags=0x00` in xAppBase.py | T-E2 |

---

## Architecture note

```
xApp (python_xapp_runner)
  ├─ REST → SubMgr :8088/ric/v1/subscriptions
  ├─ RMR  → ric network
  └─ bind-mount ./xApps/python
```

This is srsRAN's **developer lab RIC** — Python xApps in a container, not K8s `dms_cli` onboarding.

---

## E2 gotchas

- Use `--e2_node_id gnbd_001_001_00019b_0` (not legacy `gnb_` form) — [issue #26](https://github.com/srsran/oran-sc-ric/issues/26)
- KPM vs RC: `rmr_flags` tradeoff — [issue #12](https://github.com/srsran/oran-sc-ric/issues/12)

---

## Upstream contributions

Ready-made issue/PR drafts: [contributions/srsran-oran-sc-ric/](../../contributions/srsran-oran-sc-ric/)
