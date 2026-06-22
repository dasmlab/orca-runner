# Report format (orca-report-v1)

orca-runner emits machine- and human-readable reports designed to mirror the **evaluation section** of the [ORCA paper](https://arxiv.org/abs/2601.13681) pipeline — threat-class roll-up first, detailed findings second.

![Scan evaluation flow](../diagrams/svg/scan-eval-flow.svg)

## Files

| File | Purpose |
|------|---------|
| `orca-report.json` | CI artifact, schema-validated |
| `orca-report.md` | Human review, PR comments |

Schema: [`schemas/orca-report-v1.schema.json`](../schemas/orca-report-v1.schema.json)

## Top-level fields

| Field | Description |
|-------|-------------|
| `decision` | `pass` (0), `warn` (1), or `fail` (2) — pipeline exit code |
| `summary` | Short headline for the worst matched policy rule |
| `evaluation` | Threat-class roll-up (ORCA Tables 2–3 analogue) |
| `findings` | Individual rule hits with source paths |

## Evaluation block

```json
"evaluation": {
  "total_findings": 2,
  "by_threat_class": [
    {
      "threat_class": "T-E2",
      "finding_count": 2,
      "highest_severity": "medium",
      "policy_action": "warn"
    }
  ]
}
```

### Comparison to ORCA GitLab output

| ORCA (`format_extraction_output.ipynb`) | orca-runner |
|-------------------------------------------|-------------|
| `threat` column (`T-E2`, `T-ML`, …) | `threat_class` |
| `cves_count` | `finding_count` (static rules today; CVE count in future) |
| `v2_baseScore` | Not computed in v0 — use `highest_severity` + `policy_action` |
| Pickle in `extraction/` | JSON committed / CI artifact |

When we add CVE-backed rules, we intend to add optional `cvss` sub-objects per threat class without breaking v1 consumers.

## Findings block

Each finding:

```json
{
  "id": "readme-e2-id-mismatch",
  "threat_class": "T-E2",
  "severity": "medium",
  "title": "README E2 node ID examples may be stale",
  "detail": "Examples use gnb_ IDs; xApp defaults use gnbd_",
  "source": "README.md"
}
```

`id` matches `match` in policy YAML.

## Policy mapping

Policies define how findings become pipeline decisions:

```yaml
rules:
  - id: warn-readme-e2-id-mismatch
    match: readme-e2-id-mismatch
    threat_class: T-E2
    action: warn
```

`policy_action` in the evaluation table is the **worst** action among findings in that threat class.

## Samples

- [samples/clean-xapp-report.json](./samples/clean-xapp-report.json) — pass
- [samples/unsafe-xapp-report.json](./samples/unsafe-xapp-report.json) — fail
- [samples/srsran-lab-warn-report.json](./samples/srsran-lab-warn-report.json) — warn (T-E2)

## Generating reports

```bash
orca-runner check --policy policies/oran-xapp-v0.yaml \
  --report orca-report.json \
  --markdown orca-report.md \
  path/to/xapp
```
