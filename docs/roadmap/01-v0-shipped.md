# v0 — Shipped

Baseline public release. Tag: `0.0.1-alpha`.

## Delivered

- [x] Go CLI: `orca-runner check <path> --policy <yaml>`
- [x] Pass / warn / fail decision + exit codes
- [x] `orca-report.json` + `orca-report.md` with `evaluation.by_threat_class`
- [x] Policies: `oran-xapp-v0.yaml`, `oran-xapp-srsran-lab.yaml`
- [x] Examples: `clean-xapp` (pass), `unsafe-xapp` (fail)
- [x] Sample reports in `docs/samples/`
- [x] D2 diagrams → SVG + CI render workflow
- [x] srsRAN lab wrapper: `labs/setup-oran-sc-ric-lab.sh`
- [x] Contribution pack (issue draft, README patch, workflow YAML draft)

## Checks implemented (v0)

| Rule ID | Threat class | Trigger |
|---------|--------------|---------|
| `k8s-privileged-pod` | T-VM-C | `privileged: true` in YAML |
| `k8s-host-network` | T-VM-C | `hostNetwork: true` |
| `hardcoded-secret` | T-OPENSRC | Credential patterns in code |
| `xapp-descriptor-incomplete` | T-OCAPI | Missing xApp name in descriptor |
| `legacy-e2-node-id` | T-E2 | `gnb_` without `gnbd_` in code |
| `readme-e2-id-mismatch` | T-E2 | Stale README E2 examples |
| `rmr-flags-zero` | T-E2 | `rmr_flags=0x00` in xAppBase.py |

## Out of scope for v0

- CVE / CAPEC corpus (ORCA GitLab extraction path)
- Live E2 runtime validation
- GitHub Action published to Marketplace
- Blocking CI on srsRAN merges
