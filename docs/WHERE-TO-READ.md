# Where to read

## Start here

| What | Path |
|------|------|
| **Repo index** | [README.md](../README.md) |
| **Roadmap (phases)** | [00-roadmap.md](./00-roadmap.md) |
| **v0 shipped** | [roadmap/01-v0-shipped.md](./roadmap/01-v0-shipped.md) |
| **Ecosystem reality** | [roadmap/03-ecosystem-reality.md](./roadmap/03-ecosystem-reality.md) |
| **Tier 2 RAN guide** | [labs/02-tier2-ran-guide.md](./labs/02-tier2-ran-guide.md) |
| **Tier 2 validation log** | [labs/validation/03-tier2-connected.md](./labs/validation/03-tier2-connected.md) |
| **ORCA paper relationship** | [00-orca-relationship.md](./00-orca-relationship.md) |
| **Report format** | [report-format.md](./report-format.md) |
| **Sample reports** | [samples/](./samples/) |

## srsRAN lab

| What | Path |
|------|------|
| Lab guide | [labs/01-oran-sc-ric-lab-guide.md](./labs/01-oran-sc-ric-lab-guide.md) |
| **Validation log (Phase 1)** | [labs/validation/](./labs/validation/) |
| Lab script | [labs/setup-oran-sc-ric-lab.sh](../labs/setup-oran-sc-ric-lab.sh) |
| srsRAN policy | [policies/oran-xapp-srsran-lab.yaml](../policies/oran-xapp-srsran-lab.yaml) |
| Upstream contribution pack | [contributions/srsran-oran-sc-ric/](../contributions/srsran-oran-sc-ric/) |

## Build & test

```bash
make build
make check-unsafe   # expect fail (exit 2)
make check-clean    # expect pass
```

## Diagrams

```bash
./scripts/render-diagrams.sh
```

SVG outputs: [diagrams/svg/](../diagrams/svg/)

## Schema

[schemas/orca-report-v1.schema.json](../schemas/orca-report-v1.schema.json)
