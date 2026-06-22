# Scan findings → runtime pain mapping

**Phase 1.** Connect static orca-runner warnings to srsRAN community issues and what we observed in the lab.

Policy: [`policies/oran-xapp-srsran-lab.yaml`](../../policies/oran-xapp-srsran-lab.yaml)

| Finding ID | Threat class | Policy action | Community issue | What it means | Tier 1 observed | Tier 2 observed |
|------------|--------------|---------------|-----------------|---------------|-----------------|-----------------|
| `readme-e2-id-mismatch` | T-E2 | warn | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | README copy-paste uses `gnb_*`; CLIs default `gnbd_*` | ⬜ | ⬜ |
| `legacy-e2-node-id` | T-E2 | warn | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | Source still references legacy ID form | ⬜ | ⬜ |
| `rmr-flags-zero` | T-E2 | warn | [#12](https://github.com/srsran/oran-sc-ric/issues/12) | KPM vs RC `rmr_flags` tradeoff in `xAppBase.py` | ⬜ | ⬜ |
| `hardcoded-secret` | T-OPENSRC | fail | — | Credential patterns in source | N/A in upstream tree | N/A |
| `k8s-privileged-pod` | T-VM-C | fail | — | Privileged container in manifests | N/A (docker lab) | N/A |

## Papercut addressed upstream

| Fix | PR | Status |
|-----|-----|--------|
| Papercut PR: README E2 ID examples → `gnbd_001_001_00019b_0` | [srsran/oran-sc-ric#88](https://github.com/srsran/oran-sc-ric/pull/88) | ✅ open |

_Update this table when the papercut PR is open/merged._
