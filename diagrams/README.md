# Diagrams (d2 → SVG)

Source files live here as `.d2`. Rendered SVGs go to [`svg/`](./svg/) and are embedded in the README and docs.

## Render locally

```bash
./scripts/render-diagrams.sh
```

Requires [d2](https://d2lang.com/):

```bash
curl -fsSL https://d2lang.com/install.sh | sh -s --
```

## Files

| Source | Used in |
|--------|---------|
| [ci-pipeline.d2](./ci-pipeline.d2) | README |
| [scan-eval-flow.d2](./scan-eval-flow.d2) | report-format.md |
| [threat-taxonomy.d2](./threat-taxonomy.d2) | README, ORCA relationship doc |

CI re-renders on `.d2` changes via [`.github/workflows/diagrams.yml`](../.github/workflows/diagrams.yml).
