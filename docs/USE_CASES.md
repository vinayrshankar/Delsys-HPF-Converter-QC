# Use Cases

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

These scenarios are intentionally generic and are not tied to a specific study.

## Scenario 1: Three EMG sensors, each with accelerometry

### Acquisition

Three sensors each provide:

```text
EMG + ACC X + ACC Y + ACC Z
```

### Channel map

| Order | Label | Type |
|---:|---|---|
| 1 | Muscle1 | EMG + ACC |
| 2 | Muscle2 | EMG + ACC |
| 3 | Muscle3 | EMG + ACC |

### Expected streams

12 total: 3 EMG and 9 ACC.

### Use

Run QC to confirm the repeating `EMG, ACC, ACC, ACC` pattern before conversion.

---

## Scenario 2: ACC-only reference plus 12 EMG+ACC muscle sensors

### Channel map

| Order | Label | Type |
|---:|---|---|
| 1 | Reference | ACC only |
| 2 | Muscle01 | EMG + ACC |
| ... | ... | ... |
| 13 | Muscle12 | EMG + ACC |

### Expected streams

- Reference: 3 ACC
- 12 muscles: 12 EMG + 36 ACC
- Total: 51 streams

### Use

This is a common reason a hard-coded “every sensor begins with EMG” converter fails: the first device contributes ACC only.

---

## Scenario 3: ACC-only reference plus EMG-only muscle sensors

### Channel map

| Order | Label | Type |
|---:|---|---|
| 1 | Reference | ACC only |
| 2 | Muscle01 | EMG only |
| ... | ... | ... |
| 13 | Muscle12 | EMG only |

Expected total: 3 ACC + 12 EMG = 15 streams.

This can coexist in the same larger research program as Scenario 2, but it should use a separate configuration.

---

## Scenario 4: Mixed sensor modes

A recording could contain:

```text
Reference = ACC only
MuscleA = EMG + ACC
MuscleB = EMG only
MuscleC = EMG + ACC
```

The channel map can represent this directly. The expected stream sequence is generated row-by-row, so there is no requirement that every muscle sensor use the same mode.

---

## Scenario 5: EMG-only acquisition

Set each used sensor to `EMG only` and leave ACC sample-rate settings present but irrelevant to expected stream positions.

Converted output contains `_EMG.txt` plus metadata; no `_ACC.txt` is required.

---

## Scenario 6: ACC-only acquisition

Set each used sensor to `ACC only`.

Each row contributes X/Y/Z streams. Converted output contains `_ACC.txt` plus metadata.

---

## Scenario 7: Large, inconsistently nested study directory

Suppose HPF recordings exist at different depths:

```text
Root/Subject01/TaskA/Delsys/file.hpf
Root/Subject02/Session2/Device/Raw/file.hpf
Root/Subject03/VisitB/file.hpf
```

Choose `Root` as the input root and enable recursive searching. File discovery does not require a fixed nesting level.

Use filename/folder keywords to select the desired family.

---

## Scenario 8: Select files by filename keyword

If the desired recordings contain `Walk` or `Balance`, enter:

```text
Walk, Balance
```

and choose `Match ANY`.

If recordings must contain both `Pre` and `Trial`, enter:

```text
Pre, Trial
```

and choose `Match ALL`.

---

## Scenario 9: Select by folder rather than filename

If filenames are generic but all target recordings are beneath a folder containing `Motor`, enter `Motor` under include folder/path keywords.

If archive copies exist under folders containing `Backup` or `Old`, add those to exclusion folder/path keywords.

---

## Scenario 10: Same study, multiple sampling-rate configurations

If one acquisition period used ACC at one rate and another period used a different rate, create two configuration profiles.

Do **not** make tolerance so broad that both rates are silently treated as the same protocol. Separate profiles preserve QC meaning.

---

## Scenario 11: Multiple laboratories or projects on one computer

The application itself remains unchanged. Each group saves its own `.mat` configuration profiles containing:

- its file filters;
- its folder rules;
- its sensor labels/order;
- its sample-rate settings;
- its input/output locations.

This is the intended public-use model.

---

## Scenario 12: Reprocessing without overwriting

If outputs already exist, the application skips conversion for that file rather than replacing them. To intentionally regenerate a dataset, use a new output directory or explicitly manage/delete the previous derived outputs outside the application after verifying backups.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
