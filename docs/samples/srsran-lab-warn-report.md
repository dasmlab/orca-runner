# ORCA-RUNNER Report (srsRAN lab sample)

**Decision:** WARN

**Summary:** README E2 node ID examples may be stale

| Field | Value |
|-------|-------|
| Target | `labs/oran-sc-ric` |
| Policy | `policies/oran-xapp-srsran-lab.yaml` |
| Tool | orca-runner 0.1.0-alpha |

## Evaluation by threat class

| threat_class | findings | highest_severity | policy_action |
|--------------|----------|------------------|---------------|
| T-E2 | 2 | medium | warn |

**Total findings:** 2

## Findings

- **README E2 node ID examples may be stale** (`readme-e2-id-mismatch`, T-E2) — medium
  - Examples use gnb_ IDs; xApp defaults use gnbd_ — causes copy-paste failures
  - source: `README.md`
- **RMR flags default 0x00** (`rmr-flags-zero`, T-E2) — low
  - Known KPM vs RC tradeoff per oran-sc-ric issue #12
  - source: `xApps/python/lib/xAppBase.py`

_Generated from a local `./labs/setup-oran-sc-ric-lab.sh scan` run against srsran/oran-sc-ric main._
