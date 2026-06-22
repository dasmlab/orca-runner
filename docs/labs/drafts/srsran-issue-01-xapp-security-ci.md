# Draft — GitHub Issue for srsran/oran-sc-ric

**Copy everything below the line into:** https://github.com/srsran/oran-sc-ric/issues/new

---

## Title

Proposal: CI security / consistency gate for `xApps/python` (orca-runner)

## Labels (if available)

`enhancement`, `xApp`, `documentation`

---

## Body

### Summary

We've been running the dockerized Near-RT RIC lab locally (`docker compose up`) and developing xApps under `xApps/python/`. There is currently **no CI workflow** on the repo, and several recurring integration papercuts (E2 node ID format, README examples vs xApp defaults) show up repeatedly in existing issues ([#12](https://github.com/srsran/oran-sc-ric/issues/12), [#26](https://github.com/srsran/oran-sc-ric/issues/26), [#63](https://github.com/srsran/oran-sc-ric/issues/63)).

We'd like to propose a **lightweight, warn-first CI check** on `xApps/python` using **[orca-runner](https://github.com/dasmlab/orca-runner)** — an open-source CLI that maps findings to O-RAN-relevant threat classes (e.g. T-E2, T-OPENSRC) and emits Pass/Warn/Fail reports with threat-class evaluation tables aligned with the [ORCA paper](https://arxiv.org/abs/2601.13681). It is inspired by the [ORCA research PoC](https://gitlab.com/submission1660638/orca) but scoped as a **practical pre-run / pre-PR gate**, not an NLP research replica.

### What we ran locally

```bash
git clone https://github.com/dasmlab/orca-runner.git
cd orca-runner
./labs/setup-oran-sc-ric-lab.sh up
./labs/setup-oran-sc-ric-lab.sh scan
```

On current `main`, orca-runner reports **WARN** with findings including:

| Finding | Threat class | Why it matters |
|---------|--------------|----------------|
| README E2 node ID examples use `gnb_*` | T-E2 | xApp CLIs default to `gnbd_001_001_00019b_0`; copy-paste from README fails ([#26](https://github.com/srsran/oran-sc-ric/issues/26)) |
| `xAppBase.py` uses `rmr_flags=0x00` | T-E2 | Documented KPM vs RC tradeoff ([#12](https://github.com/srsran/oran-sc-ric/issues/12)) |

Sample report: [docs/samples/srsran-lab-warn-report.json](https://github.com/dasmlab/orca-runner/blob/main/docs/samples/srsran-lab-warn-report.json)

```markdown
Decision: WARN

## Evaluation by threat class
| threat_class | findings | highest_severity | policy_action |
| T-E2         | 2        | medium             | warn          |
```

### Proposal

1. **Short term (separate small PR):** Align README E2 node ID examples with xApp defaults (`gnbd_001_001_00019b_0`). Patch ready: [README-e2-node-id.patch](https://github.com/dasmlab/orca-runner/blob/main/contributions/srsran-oran-sc-ric/README-e2-node-id.patch)
2. **Follow-up:** Add `.github/workflows/xapp-security.yml` — **warn-only initially**, upload `orca-report.json` as artifact. Draft: [xapp-security.yml](https://github.com/dasmlab/orca-runner/blob/main/contributions/srsran-oran-sc-ric/xapp-security.yml)
3. **Optional:** Document recommended pre-run check in README xApp Development section.

### What we are NOT proposing

- Replacing SubMgr, RMR, or xApp framework
- Blocking merges on day one without maintainer agreement
- Claiming O-RAN SC / WG11 certification

### Ask

- Is a warn-first CI gate on `xApps/python` welcome?
- Would you prefer checks on the whole repo or only `xApps/python`?
- Any objection to aligning README E2 examples in a small docs-only PR first?

Happy to adjust policy rules or contribute the workflow once direction is confirmed.

### References

- ORCA paper: https://arxiv.org/abs/2601.13681
- orca-runner: https://github.com/dasmlab/orca-runner
- Report format: https://github.com/dasmlab/orca-runner/blob/main/docs/report-format.md
- Lab guide: https://github.com/dasmlab/orca-runner/blob/main/docs/labs/01-oran-sc-ric-lab-guide.md

---

**Submitted by:** DASMLAB  
**Contact:** (add your GitHub handle)
