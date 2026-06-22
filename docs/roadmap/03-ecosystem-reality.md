# Ecosystem reality check

Honest read on where **orca-runner** fits in the O-RAN / srsRAN landscape — updated 2026-06-22.

This is **public-facing context**, not internal GTM strategy. It explains why we use `srsran/oran-sc-ric` as a **lab rat** while planning broader targets.

---

## TL;DR

| Question | Answer |
|----------|--------|
| Is `oran-sc-ric` a hot active project? | **No** — maintainer-driven, ~8 months since last merge |
| Is it useless? | **No** — still a workable docker RIC + xApp tutorial; issues still arrive |
| Should we bet on srsRAN merging our CI? | **No** — low merge velocity; single maintainer (`pgawlowicz`) |
| Should we still run the lab? | **Yes** — cheap validation and public credibility |
| Where is srsRAN energy going? | **[OCUDU](https://ocudu.org/)** (CU/DU, Linux Foundation) — not this repo |

---

## srsRAN parent vs `oran-sc-ric`

```
srsRAN company focus (2026)
├── OCUDU (LF)          ← CU/DU "Linux of RAN" — active, funded
├── srsRAN_Project      ← archived Jun 2026 → superseded by OCUDU
└── oran-sc-ric         ← small docker Near-RT RIC + Python xApps — side lab
```

**[srsRAN_Project](https://github.com/srsran/srsRAN_Project)** was archived; maintainers ask contributors to move to OCUDU ([discussion #1470](https://github.com/srsran/srsRAN_Project/discussions/1470)).

**`oran-sc-ric`** is separate: O-RAN SC `i-release` in Docker, example KPM/RC xApps, srsRAN gNB configs for ZMQ. It was **not** announced as part of the OCUDU migration.

---

## Activity signals (oran-sc-ric, mid 2026)

| Signal | Observation |
|--------|-------------|
| Last merged PR | [#80](https://github.com/srsran/oran-sc-ric/pull/80) — 2025-10-14, `pgawlowicz` |
| Open external PRs | [#84](https://github.com/srsran/oran-sc-ric/pull/84) (Feb 2026), ours [#88](https://github.com/srsran/oran-sc-ric/pull/88) |
| CI workflows | **None** on `xApps/python` |
| Issues | Still opened (#87 May 2026) — people hit the lab |
| Contributor pattern | Essentially one maintainer merging own batches |

**Verdict:** maintenance mode / educational lab — not a vibrant multi-maintainer community.

---

## What orca-runner gets from srsRAN anyway

Even if [#88](https://github.com/srsran/oran-sc-ric/pull/88) sits open:

1. **Real tree to scan** — E2 ID drift, RMR flags, secrets patterns
2. **Tier 1 / Tier 2 validation** — documented in [labs/validation/](../labs/validation/)
3. **Public PR link** — proves we engaged upstream, not only blogged
4. **Policy tuning** — `oran-xapp-srsran-lab.yaml` grounded in SubMgr/E2 behavior

**Low-cost optionality** — not the primary adoption channel.

---

## srsRAN engagement rules (public)

| Do | Don't |
|----|-------|
| Leave papercut PR open; watch with `./scripts/watch-srsran-pr.sh` | Chase maintainers weekly |
| Complete Tier 2 for **our** samples / roadmap | Block product on srsRAN CI merge |
| Cap investment at lab + docs PR | Propose CI workflow before Phase 2 proof |
| Document honest outcomes | Claim srsRAN endorsement |

---

## Where adoption is more plausible (Phase 4+)

| Target | Why |
|--------|-----|
| **O-RAN SC** (`o-ran-sc/*`, xApp frame, CI/CT) | Production RIC path; security/SBOM specs |
| **OCUDU ecosystem** | Where CU/DU contributors concentrate post-2026 |
| **Operator / integrator xApp repos** | Real pre-deploy gates |
| **O-RAN / LF test labs** | Conformance + security artifacts |

Track in [00-roadmap.md](./00-roadmap.md) Phase 4.

---

## How this repo labels srsRAN

In our roadmap:

- **Phase 1–2:** `oran-sc-ric` = validation lab + visibility
- **Phase 3:** CI proposal only if maintainer engages
- **Phase 4:** broader O-RAN SC / OCUDU / operator targets

Tier 2 (live E2/KPM) serves **orca-runner credibility**, not srsRAN product growth.
