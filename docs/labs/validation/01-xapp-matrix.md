# xApp matrix — validation log

**Phase 1 credibility bar.** Run each example from the [oran-sc-ric lab guide](./01-oran-sc-ric-lab-guide.md).

**Lab commit tested:** _TBD_  
**Host / date:** _TBD_  
**Tier:** Tier 1 (RIC only) unless noted

## Commands

From repo root after `./labs/setup-oran-sc-ric-lab.sh up`:

```bash
docker compose exec python_xapp_runner ./simple_mon_xapp.py --metrics=DRB.UEThpDl,DRB.UEThpUl
docker compose exec python_xapp_runner ./kpm_mon_xapp.py --kpm_report_style=5
docker compose exec python_xapp_runner ./simple_rc_xapp.py
docker compose exec python_xapp_runner ./simple_rc_ho_xapp.py --e2_node_id gnbd_001_001_00019b_0 --plmn 00101 --amf_ue_ngap_id 1 --target_nr_cell_id 0x19b1
docker compose exec python_xapp_runner ./simple_ccc_xapp.py
```

## Results

| xApp | Started | SubMgr / E2 outcome | RMR / indication | Pass? | Notes |
|------|---------|---------------------|------------------|-------|-------|
| `simple_mon_xapp.py` | ⬜ | | | | |
| `kpm_mon_xapp.py` | ⬜ | | | | |
| `simple_rc_xapp.py` | ⬜ | | | | |
| `simple_rc_ho_xapp.py` | ⬜ | | | | |
| `simple_ccc_xapp.py` | ⬜ | | | | |

## orca-runner scan (same session)

```bash
./labs/setup-oran-sc-ric-lab.sh scan
```

| Finding ID | Threat class | Maps to issue | Runtime observed? |
|------------|--------------|---------------|-------------------|
| `readme-e2-id-mismatch` | T-E2 | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | ⬜ |
| `rmr-flags-zero` | T-E2 | [#12](https://github.com/srsran/oran-sc-ric/issues/12) | ⬜ |
| `legacy-e2-node-id` | T-E2 | [#26](https://github.com/srsran/oran-sc-ric/issues/26) | ⬜ |

See also [02-scan-mapping.md](./02-scan-mapping.md).
