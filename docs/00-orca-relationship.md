# ORCA relationship

orca-runner is a **practical, CI-oriented** implementation inspired by the ORCA research line — not a fork of the academic PoC.

## ORCA reference implementation

- **Paper:** [ORCA — Open RAN Continuous Security Analysis](https://arxiv.org/abs/2601.13681) (arXiv:2601.13681)
- **Code:** [gitlab.com/submission1660638/orca](https://gitlab.com/submission1660638/orca)

The GitLab repo is a **replication bundle** for the paper:

| Folder | Role |
|--------|------|
| `mapping_generator/` | Build threat → CAPEC/technique mappings from JSON threat lists |
| `extraction_generator/` | Run SFC/HFC and deep extraction pipelines against a CVE DB |
| `extraction/` | Pre-computed pickle outputs for Table 2 / Table 3 reproduction |
| `format_extraction_output.ipynb` | Jupyter notebook that renders evaluation tables |

Their evaluation output looks like:

```
CAPECs Mapping N-SFC - CVSS-Version: v2
| threat     | v2_impactScore | v2_exploitabilityScore | v2_baseScore | cves_count |
| T-E2       | 5.61           | 8.41                   | 6.17         | 3952       |
| T-OPENSRC  | ...            | ...                    | ...          | 11691      |
```

That is **corpus-scale** scoring from NVD/CVE data mapped through cosine-similarity thresholds (`cos_thrs = 0.55`).

## What orca-runner does today

![Scan evaluation flow](../diagrams/svg/scan-eval-flow.svg)

| Stage | ORCA paper | orca-runner v0 |
|-------|------------|----------------|
| Threat taxonomy | JSON threat lists + MITRE mappings | Same class names in findings (`T-E2`, `T-OPENSRC`, …) |
| Detection | NLP + CVE DB extraction | Static heuristics (YAML, secrets, E2 ID drift, descriptors) |
| Evaluation | CVSS roll-up per threat class | `evaluation.by_threat_class` table in report |
| Decision | Research tables | Policy YAML → pass / warn / fail + exit code |
| CI | Not shipped | `make build`, GitHub Actions, Tekton-ready CLI |

## Roadmap (in spirit of ORCA)

1. **v0 (now):** Static checks + threat-class evaluation table + CI artifacts
2. **v1:** Optional CVE corpus lookup (reuse ORCA mapping files, not full NLP pipeline)
3. **v2:** Pluggable extractors (container SBOM, dependency audit) feeding same report schema

## When to cite which

- Cite **ORCA paper + GitLab** for the threat taxonomy and CVE-mapping methodology.
- Cite **orca-runner** when describing the shipped CI gate, policy packs, or srsRAN integration.

We welcome collaboration with the ORCA authors; this repo is positioned as **operations tooling**, not a replacement for their research artifacts.
