# ORCA-RUNNER Report

**Decision:** FAIL

**Summary:** Potential hardcoded secret

| Field | Value |
|-------|-------|
| Target | `examples/unsafe-xapp` |
| Policy | `policies/oran-xapp-v0.yaml` |
| Tool | orca-runner 0.1.0-alpha |
| Generated | 2026-06-22T12:18:43Z |

## Evaluation by threat class

Aligned with ORCA paper evaluation tables (threat-class roll-up; see report-format.md in repo docs).

| threat_class | findings | highest_severity | policy_action |
|--------------|----------|------------------|---------------|
| T-OPENSRC | 1 | critical | fail |
| T-VM-C | 2 | high | fail |

**Total findings:** 3

## Findings

- **Potential hardcoded secret** (`hardcoded-secret`, T-OPENSRC) — critical
  - suspicious credential pattern at line 2
  - source: `examples/unsafe-xapp/app.py`
- **Privileged container requested** (`k8s-privileged-pod`, T-VM-C) — high
  - Manifest requests privileged mode
  - source: `examples/unsafe-xapp/manifest.yaml`
- **hostNetwork enabled** (`k8s-host-network`, T-VM-C) — medium
  - Pod may bypass cluster network policy
  - source: `examples/unsafe-xapp/manifest.yaml`
