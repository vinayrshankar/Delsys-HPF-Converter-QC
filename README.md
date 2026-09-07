# Delsys HPF Converter + QC

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/  
**Version:** 1.1.0

A study-agnostic MATLAB GUI for discovering, quality-checking, configuring, and converting Delsys EMGworks `.hpf` recordings into separate EMG and accelerometer text files.

Developed and maintained by **Vinay Shankar**. For questions, bug reports, or research-use discussion, contact **vinay@tfaworld.org** or visit **https://tfaworld.org/**.

## Why this project exists

Delsys HPF datasets can become difficult to process when a study contains multiple acquisition layouts, differently nested folders, inconsistent filenames, EMG-only sensors, accelerometer-only sensors, or sensors that record both EMG and 3-axis acceleration. A conversion script that hard-codes one experiment can silently assign the wrong anatomical labels to another recording.

This application separates the workflow into four explicit steps:

1. **Discover** files using configurable filename and folder rules.
2. **Describe** the expected sensor order with a reusable 16-row configuration.
3. **QC** every HPF stream by observed sampling rate and expected stream order.
4. **Convert** only recordings that pass QC, without modifying or overwriting source data.

The software is intentionally generic. Study names, task names, muscle names, folder structures, and file keywords live in user-created configuration files rather than in the application code.

## Main features

- Recursive or single-folder `.hpf` discovery.
- Filename include/exclude keyword filters.
- Folder/path include/exclude keyword filters.
- `Match ANY` or `Match ALL` filename rules.
- Up to **16 ordered sensor definitions**.
- Sensor modes: `Ignore`, `EMG only`, `ACC only`, `EMG + ACC`.
- User-defined expected EMG and ACC sampling frequencies and tolerances.
- Stream-by-stream QC comparing observed signal type with configured stream order.
- Optional deep QC that reads stream data and checks for zero-length or unequal-length signals.
- Reusable MATLAB `.mat` configuration profiles.
- Separate tab-delimited EMG and ACC outputs.
- Time columns generated from observed sampling rates.
- Timestamped QC summary and stream-audit CSV reports.
- Conversion metadata sidecars for provenance and reproducibility.
- Preserved source-folder structure when desired.
- Output-tree exclusion during recursive scans.
- Existing output files are **never overwritten**.
- Author, email, website, software version, and provenance recorded throughout generated configuration/QC/metadata products.

## Software requirements

### Required

- **Windows**. The application loads the Delsys `HPF.dll` through MATLAB's .NET interface; the distributed Delsys conversion library is Windows-based.
- **MATLAB** with `uifigure` UI components and .NET support. A current MATLAB release is recommended.
- **Delsys EMGworks / MATLAB Conversion Library** containing `HPF.dll`.
- Read access to the source `.hpf` recordings.
- Write access to a separate output directory.

### Not required by this application

- Signal Processing Toolbox is not required for the current conversion/QC workflow.
- App Designer is not required; the GUI is a single `.m` file.
- The Delsys `HPF.dll` is **not** included in this repository.

The GUI starts with this common Windows installation path as an editable default:

```text
C:\Program Files (x86)\Delsys, Inc\EMGworks\Matlab Conversion Library\HPF.dll
```

Your installation may differ. Use **Browse...** in the GUI to select the correct DLL.

See [Installation](docs/INSTALLATION.md) for a complete setup guide.

## Quick start

1. Download or clone this repository.
2. Open MATLAB on the Windows computer that has the Delsys conversion library installed.
3. Make this repository the current MATLAB folder or add it to the MATLAB path.
4. Run:

```matlab
Delsys_HPF_Converter_QC_GUI
```

5. Select `HPF.dll`.
6. Select an **input root folder** containing your HPF recordings.
7. Select a **different output root folder**.
8. Enter optional filename/folder filters.
9. Enter expected EMG/ACC sample rates and tolerances.
10. Build the ordered channel map.
11. Click **Scan Files**.
12. Click **Run QC**.
13. Inspect failures and stream-level audits.
14. Click **Convert Passed** only after confirming the configuration is correct.

See [Getting Started](docs/GETTING_STARTED.md) for a guided first run.

## Channel-map model

Each row represents one physical sensor in its expected HPF order.

| Sensor mode | Expected HPF streams |
|---|---|
| `Ignore` | No streams expected |
| `EMG only` | 1 EMG stream |
| `ACC only` | 3 ACC streams: X, Y, Z |
| `EMG + ACC` | 1 EMG stream followed by ACC X, Y, Z |

For example, this configuration:

| Order | Label | Sensor Type |
|---:|---|---|
| 1 | Head | ACC only |
| 2 | LeftMuscle | EMG + ACC |
| 3 | RightMuscle | EMG + ACC |

expects the stream sequence:

```text
HeadX, HeadY, HeadZ,
LeftMuscle EMG, LeftMuscleX, LeftMuscleY, LeftMuscleZ,
RightMuscle EMG, RightMuscleX, RightMuscleY, RightMuscleZ
```

### Critical interpretation rule

**Sampling-rate QC can help establish whether a stream behaves like EMG or ACC. It cannot independently prove the anatomical identity of that sensor.**

If a configuration says stream 4 belongs to `LeftMuscle`, the software can verify that stream 4 has the expected EMG-like sampling rate, but the anatomical label is only correct if the user has entered the acquisition order correctly. Always validate the channel map against the Delsys acquisition setup used during collection.

See [Configuration Reference](docs/CONFIGURATION_REFERENCE.md) and [QC & Validation](docs/QC_AND_VALIDATION.md).

## Configuration profiles

The GUI can save the current setup as a portable MATLAB `.mat` configuration. A configuration stores:

- input/output folder settings,
- recursive-search preference,
- filename and folder filters,
- EMG/ACC expected sampling rates,
- sample-rate tolerances,
- QC options,
- channel map,
- software name/version,
- **Vinay Shankar**,
- **vinay@tfaworld.org**,
- **https://tfaworld.org/**,
- configuration-generation timestamp.

This makes the application useful for laboratories that use several acquisition layouts. Instead of rewriting MATLAB code, save one configuration per acquisition setup.

Example names could be:

```text
UpperLimb_12Sensor.mat
Walking_15Sensor.mat
EMGOnly_8Channel.mat
HeadACC_MuscleEMG.mat
Pilot_74Hz_ACC.mat
```

The application itself does not depend on any of those names.

## QC logic

QC occurs before conversion.

### Standard QC

For each HPF file, the application:

1. reads every HPF stream's sampling rate,
2. classifies each stream as `EMG`, `ACC`, or `UNEXPECTED` using configured sample rates and tolerances,
3. builds the expected stream sequence from the channel map,
4. compares actual stream count with expected stream count,
5. compares observed signal type against expected type at every stream position,
6. records a PASS/FAIL result and a stream-level audit.

### Deep QC

When enabled, Deep QC additionally reads the signal arrays and checks that:

- every expected stream returns samples,
- all EMG streams have the same sample count,
- all ACC streams have the same sample count.

A PASS means the file is consistent with the **configuration you supplied**. It does not prove electrode placement, anatomical placement, calibration, signal quality, or physiological validity.

See [QC & Validation](docs/QC_AND_VALIDATION.md).

## Output files

For a source file:

```text
recording.hpf
```

the application may create:

```text
recording_EMG.txt
recording_ACC.txt
recording_ConversionMetadata.txt
```

Only the signal types present in the configured map are written.

### EMG/ACC text files

The first column is `Time`; subsequent columns use the configured labels. MATLAB sanitizes labels when necessary to create valid table-variable names and makes duplicates unique.

### Conversion metadata

The sidecar records provenance including:

- software name and version,
- **Author: Vinay Shankar**,
- **Email: vinay@tfaworld.org**,
- **Website: https://tfaworld.org/**,
- conversion timestamp,
- source HPF path,
- configured EMG and ACC sample rates,
- observed mean sampling rates,
- expected stream count,
- generated output paths.

### QC reports

QC reports are stored in an output `QC_Reports` folder and contain software author/contact/version fields alongside file and stream results.

See [Output Formats](docs/OUTPUT_FORMATS.md).

## Data safety

The application is designed around a conservative research-data workflow:

- source `.hpf` files are opened for reading, not rewritten;
- input and output roots must be different;
- recursive scans exclude the configured output tree;
- existing required outputs cause that source recording to be skipped;
- conversion is blocked until QC has been run for the current configuration;
- changing the configuration invalidates previous QC.

No software can substitute for a validated backup policy. Keep original HPF recordings in protected storage and test a new configuration on a small subset before batch conversion.

## Common use cases

This application can support, among others:

1. **EMG-only acquisition** — multiple EMG sensors with no accelerometry.
2. **ACC-only acquisition** — one or more accelerometer sensors.
3. **EMG + ACC acquisition** — each muscle sensor has EMG plus X/Y/Z acceleration.
4. **Mixed acquisition** — an ACC-only reference/head sensor plus EMG+ACC muscle sensors.
5. **Mixed sensor types** — some EMG-only sensors and some EMG+ACC sensors in one file.
6. **Large nested studies** — HPF files scattered through participant/session/task folders.
7. **Keyword-based task selection** — include files containing one or several task terms.
8. **Folder-based selection** — restrict processing to paths containing or excluding specific terms.
9. **Different acquisition configurations** — save a separate `.mat` configuration for each layout.
10. **Non-default sampling rates** — explicitly configure and QC a second acquisition protocol rather than forcing it into the default rates.

Detailed walkthroughs are in [Use Cases](docs/USE_CASES.md).

## Documentation

- [Documentation index](docs/README.md)
- [Installation and software requirements](docs/INSTALLATION.md)
- [Getting started](docs/GETTING_STARTED.md)
- [Configuration reference](docs/CONFIGURATION_REFERENCE.md)
- [QC and validation guide](docs/QC_AND_VALIDATION.md)
- [Validation checklist](docs/VALIDATION_CHECKLIST.md)
- [Use cases and workflow examples](docs/USE_CASES.md)
- [Output formats and provenance](docs/OUTPUT_FORMATS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [FAQ](docs/FAQ.md)
- [Developer overview](docs/DEVELOPER_OVERVIEW.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)

## Delsys notice

Delsys, Trigno, EMGworks, and related names are trademarks or products of their respective owners. This project is an independent MATLAB utility authored by **Vinay Shankar** and is not presented as an official Delsys product.

`HPF.dll` is not distributed by this repository. Users must obtain the appropriate Delsys software/library through their own installation and licensing arrangements.

## Citation

If you use this software in academic or research work, please cite the software using [`CITATION.cff`](CITATION.cff).

**Vinay Shankar**  
**vinay@tfaworld.org**  
**https://tfaworld.org/**

## Copyright

Copyright © 2026 **Vinay Shankar**. All rights reserved.

No open-source license has been selected in this release. See [`COPYRIGHT.md`](COPYRIGHT.md).

---

**Author:** Vinay Shankar · **Email:** vinay@tfaworld.org · **Website:** https://tfaworld.org/
