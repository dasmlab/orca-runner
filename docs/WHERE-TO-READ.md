# Where to read

## Start here

| What | Path |
|------|------|
| **Repo index** | [README.md](../README.md) |
| **ORCA paper relationship** | [00-orca-relationship.md](./00-orca-relationship.md) |
| **Report format** | [report-format.md](./report-format.md) |
| **Sample reports** | [samples/](./samples/) |

## srsRAN lab

| What | Path |
|------|------|
| Lab guide | [labs/01-oran-sc-ric-lab-guide.md](./labs/01-oran-sc-ric-lab-guide.md) |
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
