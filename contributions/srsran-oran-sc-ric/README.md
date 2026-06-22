# srsran/oran-sc-ric contribution pack

Ready-to-use artifacts for upstream engagement. Link this repo in PRs and issues.

| Step | File | Action |
|------|------|--------|
| **1 — Issue** | [../../docs/labs/drafts/srsran-issue-01-xapp-security-ci.md](../../docs/labs/drafts/srsran-issue-01-xapp-security-ci.md) | Paste into GitHub new issue |
| **2 — Papercut PR** | [../../docs/labs/drafts/srsran-pr-01-readme-e2-node-id.md](../../docs/labs/drafts/srsran-pr-01-readme-e2-node-id.md) | Fork, apply patch, open PR |
| **Patch** | [README-e2-node-id.patch](./README-e2-node-id.patch) | `git apply` on fork |
| **3 — CI PR (later)** | [xapp-security.yml](./xapp-security.yml) | After issue discussion |

## Quick submit (papercut PR)

```bash
git clone git@github.com:YOURUSER/oran-sc-ric.git
cd oran-sc-ric
git checkout -b docs/align-readme-e2-node-id-examples
patch -p1 < "$(curl -fsSL https://raw.githubusercontent.com/dasmlab/orca-runner/main/contributions/srsran-oran-sc-ric/README-e2-node-id.patch)"
git add README.md && git commit -m "docs: align README E2 node ID examples with xApp defaults"
git push origin docs/align-readme-e2-node-id-examples
```

## Order

1. **Papercut PR** or **issue** — show you've run the lab
2. Merge docs PR — low risk
3. **Workflow PR** — references https://github.com/dasmlab/orca-runner
