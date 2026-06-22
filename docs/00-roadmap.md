# Roadmap

Public plan for orca-runner — what exists today, what we are validating next, and when we propose upstream CI.

**Not** a product strategy doc. For ORCA background see [00-orca-relationship.md](./00-orca-relationship.md).

---

## Status

| Milestone | State | Tag / note |
|-----------|-------|------------|
| v0 CLI + policy packs | **Done** | `0.0.1-alpha` |
| ORCA-aligned report (`evaluation.by_threat_class`) | **Done** | `0.0.1-alpha` |
| srsRAN lab wrapper + scan policy | **Done** | `0.0.1-alpha` |
| Public roadmap scaffold | **Done** | `0.1.0-alpha` |
| srsRAN papercut PR (README E2 IDs) | **Open** | [srsran/oran-sc-ric#88](https://github.com/srsran/oran-sc-ric/pull/88) |
| Lab credibility bar (minimum) | **Planned** | Phase 1 |
| Tier 2 RAN + live KPM | **Planned** | Phase 2 |
| srsRAN CI workflow proposal | **Planned** | Phase 3 — after credibility bar |

---

## Phases

### Phase 0 — Ship the tool (complete)

- [x] Go CLI: `orca-runner check <path> --policy <yaml>`
- [x] Pass / warn / fail + `orca-report.json` / `.md`
- [x] Example policies: `oran-xapp-v0`, `oran-xapp-srsran-lab`
- [x] Committed sample reports under [samples/](./samples/)
- [x] D2 diagrams → SVG, CI workflows on this repo

### Phase 1 — Light upstream visibility (current)

**Goal:** Show we run the srsRAN docker lab and fix something small they already know is painful.

| Task | Status | Artifact |
|------|--------|----------|
| Papercut PR: README `gnb_*` → `gnbd_*` examples | ✅ open | [srsran/oran-sc-ric#88](https://github.com/srsran/oran-sc-ric/pull/88) |
| Link public repo in PR body | 🔄 | https://github.com/dasmlab/orca-runner |
| xApp matrix on Tier 1 (no gNB) | ⬜ | [labs/validation/01-xapp-matrix.md](./labs/validation/01-xapp-matrix.md) |
| `orca-runner scan` notes (warning → runtime pain) | ⬜ | [labs/validation/02-scan-mapping.md](./labs/validation/02-scan-mapping.md) |

**Credibility bar (minimum)** — enough for a discussion issue, not yet for CI merge:

1. Tier 1 `up` / `status` / `down` repeatable
2. Run each shipped example xApp once; record outcome
3. Document which orca-runner warnings map to which community issues ([#12](https://github.com/srsran/oran-sc-ric/issues/12), [#26](https://github.com/srsran/oran-sc-ric/issues/26), [#63](https://github.com/srsran/oran-sc-ric/issues/63))

### Phase 2 — Runtime validation (next minor work)

**Goal:** Honest “we connected E2” story before asking maintainers to run us on every PR.

| Task | Status | Artifact |
|------|--------|----------|
| Tier 2: Open5GS + srsRAN gNB + srsUE (ZMQ) | ⬜ | Lab guide update |
| ≥1 successful KPM `RIC_INDICATION` | ⬜ | Log + optional screenshot |
| E2 node ID check vs live gNB | ⬜ | New or tightened `T-E2` rule |
| Sample report: connected lab vs clone-only | ⬜ | `docs/samples/srsran-lab-connected-report.json` |

### Phase 3 — CI proposal (after Phase 2)

**Goal:** Warn-only GitHub Actions workflow on `xApps/python` — maintainer opt-in.

| Task | Status | Artifact |
|------|--------|----------|
| Discussion issue (not workflow-first) | ⬜ | [draft](./labs/drafts/srsran-issue-01-xapp-security-ci.md) |
| Workflow PR (warn-only + artifact upload) | ⬜ | [xapp-security.yml](../contributions/srsran-oran-sc-ric/xapp-security.yml) |
| Tighten policy from Phase 1–2 learnings | ⬜ | `oran-xapp-srsran-lab.yaml` |

### Phase 4 — Deeper ORCA alignment (future)

- Optional CVE / CAPEC lookup using [ORCA mapping artifacts](https://gitlab.com/submission1660638/orca) (not NLP replica)
- Container / SBOM checks
- Tekton task + GitHub Action wrapper package
- K8s onboarding path (when targets ship Helm charts)

---

## Example xApp matrix (Phase 1 checklist)

| xApp | Exercises | Tier 1 (no gNB) | Tier 2 (with gNB) | Notes |
|------|-----------|-----------------|-------------------|-------|
| `simple_mon_xapp.py` | KPM subscribe | ⬜ | ⬜ | |
| `kpm_mon_xapp.py` | KPM report styles 1–5 | ⬜ | ⬜ | |
| `simple_rc_xapp.py` | E2SM-RC control | ⬜ | ⬜ | |
| `simple_rc_ho_xapp.py` | Handover | ⬜ | ⬜ | |
| `simple_ccc_xapp.py` | CCC | ⬜ | ⬜ | |

Fill results in [labs/validation/01-xapp-matrix.md](./labs/validation/01-xapp-matrix.md).

---

## How to follow along

- **Releases:** [GitHub tags](https://github.com/dasmlab/orca-runner/tags)
- **Lab work:** [labs/01-oran-sc-ric-lab-guide.md](./labs/01-oran-sc-ric-lab-guide.md)
- **Contributions:** [contributions/srsran-oran-sc-ric/](../contributions/srsran-oran-sc-ric/)

Updates to this file ship with tagged commits (`./commitme.sh minor|point "..."`).
