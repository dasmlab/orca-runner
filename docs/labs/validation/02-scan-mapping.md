# Scan findings → runtime pain mapping

Policy: [`policies/oran-xapp-srsran-lab.yaml`](../../policies/oran-xapp-srsran-lab.yaml)  
Lab commit: `621ade2` (2026-06-22)

| Finding ID | Threat class | Policy action | Community issue | What it means | Tier 1 observed | Tier 2 observed |
|------------|--------------|---------------|-----------------|---------------|-----------------|-----------------|
| `readme-e2-id-mismatch` | T-E2 | warn | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | README copy-paste uses `gnb_*`; CLIs default `gnbd_*` | ✅ static + SubMgr expects `gnbd_001_001_00019b_0` | ⬜ |
| `legacy-e2-node-id` | T-E2 | warn | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | Source references legacy ID form | — (not on this tree) | ⬜ |
| `rmr-flags-zero` | T-E2 | warn | [#12](https://github.com/srsran/oran-sc-ric/issues/12) | KPM vs RC `rmr_flags` tradeoff in `xAppBase.py` | ✅ present in tree | ⬜ |
| `hardcoded-secret` | T-OPENSRC | fail | — | Credential patterns in source | N/A upstream | N/A |
| `k8s-privileged-pod` | T-VM-C | fail | — | Privileged container in manifests | N/A (docker lab) | N/A |

## Papercut addressed upstream

| Fix | PR | Status |
|-----|-----|--------|
| README E2 ID examples → `gnbd_001_001_00019b_0` | [srsran/oran-sc-ric#88](https://github.com/srsran/oran-sc-ric/pull/88) | **Open** — track with `./scripts/watch-srsran-pr.sh` |

## Runtime ↔ static link (Tier 1)

| Static warning | Runtime signal (no gNB) |
|----------------|-------------------------|
| `readme-e2-id-mismatch` | SubMgr log: `No E2 connection for ranName gnbd_001_001_00019b_0` — xApps already use `gnbd_` form |
| `rmr-flags-zero` | KPM xApps fail subscribe at SubMgr before RMR indications matter |

After PR #88 merges, `readme-e2-id-mismatch` should clear on upstream `main`.
