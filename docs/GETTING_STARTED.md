# Getting Started

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

This walkthrough assumes you have MATLAB, a working Delsys `HPF.dll`, and at least one HPF recording whose sensor order you know.

## Step 1: Launch

```matlab
Delsys_HPF_Converter_QC_GUI
```

## Step 2: Select the DLL

Use the `Delsys HPF.dll` field. Browse if the default installation path does not match your computer.

## Step 3: Select input and output roots

### Input root

Choose the highest folder you want the application to search.

If your data look like:

```text
Study/
  Participant01/
    SessionA/
      Task/
        recording.hpf
  Participant02/
    OtherFolder/
      recording.hpf
```

select `Study` and enable recursive searching.

### Output root

Select a different folder. Do not use the same root as the raw HPF files.

If `Preserve source folder structure in output` is enabled, nested source paths are recreated beneath the output root.

## Step 4: Define file-selection rules

### Include filename keywords

Examples:

```text
MVC
Walk, Balance
Pre; Post
```

`Match ANY` means at least one include term must appear. `Match ALL` means every include term must appear.

### Exclude filename keywords

Examples:

```text
test, backup, copy
```

### Include folder/path keywords

Use this when filenames are generic but folder location identifies the relevant task/session.

### Exclude folder/path keywords

Useful for excluding folders such as:

```text
archive, old, backup, converted
```

## Step 5: Define sample-rate rules

Enter the expected EMG and ACC sample rates and tolerances for the acquisition configuration you are processing.

The defaults are examples commonly seen in one Delsys export configuration; they are **not universal truth**. Your acquisition may differ.

If a known protocol uses another ACC sampling rate, create a separate configuration for that protocol rather than increasing tolerance until it passes.

## Step 6: Build the channel map

Open the Channel Map tab.

Each row represents one sensor in original acquisition order.

Example A — two EMG-only sensors:

| Order | Label | Type |
|---:|---|---|
| 1 | MuscleA | EMG only |
| 2 | MuscleB | EMG only |

Expected HPF streams: `EMG, EMG`.

Example B — ACC-only reference + one muscle sensor with EMG/ACC:

| Order | Label | Type |
|---:|---|---|
| 1 | Reference | ACC only |
| 2 | MuscleA | EMG + ACC |

Expected streams:

```text
ReferenceX, ReferenceY, ReferenceZ,
MuscleA EMG, MuscleAX, MuscleAY, MuscleAZ
```

Unused rows should remain `Ignore`.

## Step 7: Save the configuration

Click **Save Configuration...** and give it a meaningful name.

A good filename describes the acquisition layout, not a specific participant:

```text
12Sensor_EMG_ACC.mat
8Channel_EMGOnly.mat
ReferenceACC_14EMG.mat
```

## Step 8: Scan files

Click **Scan Files**.

Review the file list before running QC. Uncheck `Use` for any recording you do not want to process in that run.

## Step 9: Run QC

Click **Run QC**.

Select a file in the summary table to inspect its stream audit.

Do not convert simply because a file says PASS. First verify that the configured anatomical labels represent the actual acquisition order.

## Step 10: Convert passed files

Click **Convert Passed**.

The application creates separate EMG/ACC text outputs as appropriate plus a metadata sidecar. Existing outputs are not overwritten.

## Step 11: Archive the QC report

Use **Export QC Report** or retain the automatically produced reports in the output `QC_Reports` folder. Keep the configuration `.mat` alongside your analysis documentation so the export can be reproduced later.

## Recommended research record

For a reproducible dataset, retain together:

- original HPF files;
- software version;
- configuration `.mat`;
- QC summary CSV;
- stream-audit CSV;
- converted outputs;
- conversion metadata sidecars;
- acquisition notes that establish sensor/anatomical order.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
