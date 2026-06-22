# xApp matrix — validation log

**Phase 1 credibility bar.** Tier 1 (RIC only, no gNB).

| Field | Value |
|-------|-------|
| **Lab commit** | `621ade2` ([srsran/oran-sc-ric](https://github.com/srsran/oran-sc-ric)) |
| **Host / date** | 2026-06-22, docker compose Tier 1 |
| **RIC containers** | 7/7 Up (`ric_*`, `python_xapp_runner`) |

## Commands

From repo root after `./labs/setup-oran-sc-ric-lab.sh up`:

```bash
docker compose exec python_xapp_runner ./simple_mon_xapp.py --metrics=DRB.UEThpDl,DRB.UEThpUl
docker compose exec python_xapp_runner ./kpm_mon_xapp.py --kpm_report_style=5
docker compose exec python_xapp_runner ./simple_rc_xapp.py
docker compose exec python_xapp_runner ./simple_rc_ho_xapp.py --e2_node_id gnbd_001_001_00019b_0 --plmn 00101 --amf_ue_ngap_id 1 --target_nr_cell_id 0x19b1
docker compose exec python_xapp_runner ./simple_ccc_xapp.py
```

Each test: fresh `python_xapp_runner` restart, 20s timeout where noted.

## Results

| xApp | Started | SubMgr / E2 outcome | RMR / indication | Tier 1 pass? | Notes |
|------|---------|---------------------|------------------|--------------|-------|
| `simple_mon_xapp.py` | ✅ | ❌ SubMgr **503** — `No E2 connection for ranName gnbd_001_001_00019b_0` | — | **Expected fail** | No gNB; matches lab guide |
| `kpm_mon_xapp.py` | ✅ | ❌ Same SubMgr 503 | — | **Expected fail** | KPM subscribe needs E2 node |
| `simple_rc_xapp.py` | ✅ | n/a (no subscribe in window) | ✅ RMR init; runs until timeout | **Partial** | RC loop starts; no E2 response without gNB |
| `simple_rc_ho_xapp.py` | ✅ | n/a | ✅ Sent HO command with `gnbd_001_001_00019b_0` | **CLI ok** | Exit 0; one-shot control, no live HO |
| `simple_ccc_xapp.py` | ✅ | n/a | ✅ RMR init; runs until timeout | **Partial** | CCC xApp starts; periodic control |

### SubMgr evidence

```
No E2 connection for ranName gnbd_001_001_00019b_0
```

This confirms xApps use the **`gnbd_`** form at runtime — supports papercut PR [#88](https://github.com/srsran/oran-sc-ric/pull/88).

## orca-runner scan (same session)

```bash
orca-runner check --policy policies/oran-xapp-srsran-lab.yaml labs/oran-sc-ric
# decision: warn (exit 1)
```

| Finding ID | Threat class | Maps to issue | Tier 1 observed? |
|------------|--------------|---------------|------------------|
| `readme-e2-id-mismatch` | T-E2 | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | ✅ README still has `gnb_*` at commit `621ade2` |
| `rmr-flags-zero` | T-E2 | [#12](https://github.com/srsran/oran-sc-ric/issues/12) | ✅ `xAppBase.py` uses `rmr_flags=0x00` |
| `legacy-e2-node-id` | T-E2 | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | not triggered on this tree |

See [02-scan-mapping.md](./02-scan-mapping.md).

## Phase 1 bar status

| Criterion | Status |
|-----------|--------|
| Tier 1 `up` / `status` repeatable | ✅ |
| Each example xApp run once | ✅ |
| Scan warnings mapped to issues | ✅ |
| Tier 2 live KPM | ⬜ Phase 2 |
