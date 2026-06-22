# orca-runner

**O-RAN CI threat gate — practical OSS aligned with the [ORCA paper](https://arxiv.org/abs/2601.13681).**

The [ORCA research PoC](https://gitlab.com/submission1660638/orca) maps O-RAN threat classes to CVE/CAPEC corpora and produces evaluation tables (SFC/HFC, N-SFC). **orca-runner** ships a drop-in CLI and CI workflow that:

1. Scans xApp / rApp trees with static checks
2. Maps findings to ORCA threat classes (`T-E2`, `T-OPENSRC`, `T-VM-C`, …)
3. Emits **Pass / Warn / Fail** plus JSON and Markdown reports with **threat-class evaluation roll-ups**

![CI pipeline](./diagrams/svg/ci-pipeline.svg)

## Quick start

```bash
git clone https://github.com/dasmlab/orca-runner.git
cd orca-runner
make build
make check-unsafe   # expect fail (exit 2)
make check-clean    # expect pass
```

```bash
orca-runner check --policy policies/oran-xapp-v0.yaml examples/clean-xapp
# → orca-report.json, orca-report.md
```

## Sample output

See [`docs/samples/`](./docs/samples/) for committed example reports.

**Evaluation table** (ORCA Tables 2–3 style roll-up):

| threat_class | findings | highest_severity | policy_action |
|--------------|----------|------------------|---------------|
| T-E2 | 2 | medium | warn |
| T-OPENSRC | 0 | — | pass |

Full format: [docs/report-format.md](./docs/report-format.md)

## Relationship to ORCA

| | [ORCA (paper / GitLab)](https://gitlab.com/submission1660638/orca) | **orca-runner** (this repo) |
|---|-----|-----|
| Goal | Research: CVE ↔ threat-class mapping at scale | **Shippable** CI gate for xApp repos |
| Input | CVE DB, MITRE CAPEC/technique corpora | Source tree + policy YAML |
| Output | Pickle extractions, Jupyter evaluation tables | `orca-report.json` / `.md` + exit code |
| Threat classes | Full taxonomy (`T-E2`, `T-ML`, `T-RADIO`, …) | Subset with static rules; extensible |

![Threat taxonomy](./diagrams/svg/threat-taxonomy.svg)

Details: [docs/00-orca-relationship.md](./docs/00-orca-relationship.md)

## Policies

| Policy | Use case |
|--------|----------|
| [`policies/oran-xapp-v0.yaml`](./policies/oran-xapp-v0.yaml) | Generic O-RAN xApp (K8s, secrets, descriptors) |
| [`policies/oran-xapp-srsran-lab.yaml`](./policies/oran-xapp-srsran-lab.yaml) | [srsRAN oran-sc-ric](https://github.com/srsran/oran-sc-ric) xApp tree |

## srsRAN lab integration

```bash
./labs/setup-oran-sc-ric-lab.sh up
./labs/setup-oran-sc-ric-lab.sh scan
```

Guide: [docs/labs/01-oran-sc-ric-lab-guide.md](./docs/labs/01-oran-sc-ric-lab-guide.md)

Contribution pack for upstream PRs: [contributions/srsran-oran-sc-ric/](./contributions/srsran-oran-sc-ric/)

## CI usage

```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.24'
- run: make build
- run: orca-runner check --policy policies/oran-xapp-v0.yaml xApps/python
```

Example workflow for srsRAN: [contributions/srsran-oran-sc-ric/xapp-security.yml](./contributions/srsran-oran-sc-ric/xapp-security.yml)

## Docs map

→ [docs/WHERE-TO-READ.md](./docs/WHERE-TO-READ.md)  
→ [docs/00-roadmap.md](./docs/00-roadmap.md) — public plan and phase checklist

## Diagrams

Source: [`diagrams/*.d2`](./diagrams/) → SVG via [d2](https://d2lang.com/)

```bash
./scripts/render-diagrams.sh
```

## License

Apache 2.0 — see [LICENSE](./LICENSE)

## Citation

If you use orca-runner in research, cite the ORCA paper and this repository:

```bibtex
@article{orca2026,
  title={ORCA - Open RAN Continuous Security Analysis},
  journal={arXiv:2601.13681},
  year={2026}
}
```
