# srsRAN — Light touch

**Goal:** Become visible in the srsRAN community with a low-risk, high-signal contribution — before proposing CI.

## Target repo

[srsran/oran-sc-ric](https://github.com/srsran/oran-sc-ric) — dockerized Near-RT RIC + Python xApps.

## Why this first

- No existing GitHub Actions on `xApps/python`
- Open issues document real pain ([#12](https://github.com/srsran/oran-sc-ric/issues/12), [#26](https://github.com/srsran/oran-sc-ric/issues/26), [#63](https://github.com/srsran/oran-sc-ric/issues/63))
- orca-runner already flags README E2 drift on their tree

## Tasks

### Papercut PR (README E2 node IDs)

- [x] Patch prepared: [README-e2-node-id.patch](../../contributions/srsran-oran-sc-ric/README-e2-node-id.patch)
- [x] Branch committed locally: `docs/align-readme-e2-node-id-examples`
- [ ] Fork `srsran/oran-sc-ric` → your GitHub account
- [ ] Push branch + open PR (see [submit-papercut-pr.sh](../../contributions/srsran-oran-sc-ric/submit-papercut-pr.sh))
- [ ] Link PR in this file once open

**PR title:** `docs: align README E2 node ID examples with xApp defaults`

**Link orca-runner in PR body:** https://github.com/dasmlab/orca-runner

### Optional: comment on #26

- [ ] Add lab note + link to sample warn report: [srsran-lab-warn-report.json](../samples/srsran-lab-warn-report.json)

### Explicitly NOT in light touch

- [ ] CI workflow PR (deferred to [04-ci-proposal.md](./04-ci-proposal.md))
- [ ] Issue proposing warn-only gate (after credibility bar, or alongside papercut if maintainers engage)

## Evidence we can cite today

| Evidence | Location |
|----------|----------|
| Tier 1 RIC `docker compose up` | [lab guide](../labs/01-oran-sc-ric-lab-guide.md) |
| Static scan WARN on clone | [srsran-lab-warn-report.json](../samples/srsran-lab-warn-report.json) |
| README fix | papercut PR |

## PR tracking

| Item | URL |
|------|-----|
| Papercut PR | _pending — fill after push_ |
