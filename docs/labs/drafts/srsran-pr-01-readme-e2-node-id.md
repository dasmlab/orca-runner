# Draft — Papercut PR for srsran/oran-sc-ric

**Branch name suggestion:** `docs/align-readme-e2-node-id-examples`

**Base:** `main`

---

## PR Title

docs: align README E2 node ID examples with xApp defaults

---

## PR Body

### Why

Several xApps default to `--e2_node_id gnbd_001_001_00019b_0`, but README examples still use the legacy `gnb_001_001_*` form. This matches confusion reported in [#26](https://github.com/srsran/oran-sc-ric/issues/26) and causes copy-paste failures when running RC / handover examples.

This is a **docs-only** change — no runtime behavior change.

### Changes

- Update README command examples to use `gnbd_001_001_00019b_0`
- Update sample console output to use consistent E2 node ID format
- Add a short note under Example xApp pointing to `--e2_node_id` default in xApp CLIs

### How we found it

Running [orca-runner](https://github.com/dasmlab/orca-runner) with `policies/oran-xapp-srsran-lab.yaml` flags `readme-e2-id-mismatch` (T-E2) on the repo.

### Testing

Docs only — verified xApp defaults:

```bash
grep -r "default='gnbd_" xApps/python/*.py
```

### Related

- Issue #26 (E2 agent ID mismatch)
- Follow-up: CI security gate discussion (separate issue/PR)

---

## Diff to apply (README.md)

Apply these replacements in `README.md`:

### 1. Sample KPM console output (~line 132)

```diff
-RIC Indication Received from gnb_001_001_0000019b for Subscription ID: 65
+RIC Indication Received from gnbd_001_001_00019b_0 for Subscription ID: 65
```

### 2. Sample RC console output (~lines 163–166)

```diff
-11:34:29 Send RIC Control Request to E2 node ID: gnb_001_001_00019b for UE ID: 0, PRB_min: 1, PRB_max: 5
-11:34:34 Send RIC Control Request to E2 node ID: gnb_001_001_00019b for UE ID: 0, PRB_min: 1, PRB_max: 275
-11:34:39 Send RIC Control Request to E2 node ID: gnb_001_001_00019b for UE ID: 0, PRB_min: 1, PRB_max: 5
-11:34:44 Send RIC Control Request to E2 node ID: gnb_001_001_00019b for UE ID: 0, PRB_min: 1, PRB_max: 275
+11:34:29 Send RIC Control Request to E2 node ID: gnbd_001_001_00019b_0 for UE ID: 0, PRB_min: 1, PRB_max: 5
+11:34:34 Send RIC Control Request to E2 node ID: gnbd_001_001_00019b_0 for UE ID: 0, PRB_min: 1, PRB_max: 275
+11:34:39 Send RIC Control Request to E2 node ID: gnbd_001_001_00019b_0 for UE ID: 0, PRB_min: 1, PRB_max: 5
+11:34:44 Send RIC Control Request to E2 node ID: gnbd_001_001_00019b_0 for UE ID: 0, PRB_min: 1, PRB_max: 275
```

### 3. Handover command examples (~lines 176, 182)

```diff
-docker compose exec python_xapp_runner ./simple_rc_ho_xapp.py --e2_node_id gnb_001_001_0000019b --plmn 00101 --amf_ue_ngap_id 1 --target_nr_cell_id 0x19b1
+docker compose exec python_xapp_runner ./simple_rc_ho_xapp.py --e2_node_id gnbd_001_001_00019b_0 --plmn 00101 --amf_ue_ngap_id 1 --target_nr_cell_id 0x19b1
```

```diff
-docker compose exec python_xapp_runner ./simple_rc_ho_xapp.py --e2_node_id gnb_001_001_0000019b --plmn 00101 --amf_ue_ngap_id 1 --target_nr_cell_id 0x19b0
+docker compose exec python_xapp_runner ./simple_rc_ho_xapp.py --e2_node_id gnbd_001_001_00019b_0 --plmn 00101 --amf_ue_ngap_id 1 --target_nr_cell_id 0x19b0
```

### 4. Optional note to add after "Example xApp" quick start (~line 127)

```markdown
**Note:** Example xApps default to `--e2_node_id gnbd_001_001_00019b_0`. Use the E2 node ID reported by your gNB/E2 agent setup if it differs (see [#26](https://github.com/srsran/oran-sc-ric/issues/26)).
```

---

## Fork workflow (how to submit)

```bash
# On GitHub: fork srsran/oran-sc-ric to your account first

git clone git@github.com:YOURUSER/oran-sc-ric.git
cd oran-sc-ric
git remote add upstream https://github.com/srsran/oran-sc-ric.git
git checkout -b docs/align-readme-e2-node-id-examples

# Apply README edits (or cherry-pick from vigie contributions patch)
# ... edit README.md per diff above ...

git add README.md
git commit -m "docs: align README E2 node ID examples with xApp defaults"
git push origin docs/align-readme-e2-node-id-examples

gh pr create --repo srsran/oran-sc-ric \
  --title "docs: align README E2 node ID examples with xApp defaults" \
  --body-file /path/to/this/file/pr-body-snippet.txt
```

**PR body snippet file** — save top section (## PR Body) only for `gh pr create --body-file`.

---

## After merge

Re-run locally:

```bash
cd /home/dasm/vigie/orca-runner
./labs/setup-oran-sc-ric-lab.sh scan
```

Expected: `readme-e2-id-mismatch` warning **gone** (may still warn on `rmr_flags` until documented/addressed separately).
