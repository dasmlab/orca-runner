# srsRAN — Light touch

**Goal:** Become visible in the srsRAN community with a low-risk, high-signal contribution — before proposing CI.

## Target repo

[srsran/oran-sc-ric](https://github.com/srsran/oran-sc-ric) — dockerized Near-RT RIC + Python xApps.

## Why this first

- No existing GitHub Actions on `xApps/python`
- Open issues document real pain ([#12](https://github.com/srsran/oran-sc-ric/issues/12), [#26](https://github.com/srsran/oran-sc-ric/issues/26), [#63](https://github.com/srsran/oran-sc-ric/issues/63))
- orca-runner flags README E2 drift on their tree

## Tasks

### Papercut PR (README E2 node IDs)

- [x] Patch: [README-e2-node-id.patch](../../contributions/srsran-oran-sc-ric/README-e2-node-id.patch)
- [x] PR opened: **[#88](https://github.com/srsran/oran-sc-ric/pull/88)** — `docs: align README E2 node ID examples with xApp defaults`
- [ ] PR merged

**orca-runner linked in PR:** https://github.com/dasmlab/orca-runner

### Optional: comment on #26

- [ ] Add lab note + link to [srsran-lab-warn-report.json](../samples/srsran-lab-warn-report.json)

### Explicitly NOT in light touch

- CI workflow PR — deferred to Phase 3 in [00-roadmap.md](../00-roadmap.md)
- Warn-only gate issue — after Phase 1 credibility bar

## Evidence cited in PR #88

| Evidence | Location |
|----------|----------|
| Tier 1 RIC `docker compose up` | [lab guide](../labs/01-oran-sc-ric-lab-guide.md) |
| Static scan WARN on clone | [srsran-lab-warn-report.json](../samples/srsran-lab-warn-report.json) |
| Public roadmap | [00-roadmap.md](../00-roadmap.md) |
