# Delsys HPF Converter + QC

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Version:** 1.1.0  
**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

A study-agnostic MATLAB GUI for discovering, quality-checking, configuring, and converting Delsys EMGworks `.hpf` recordings into separate EMG and accelerometer text files.

## Why this project exists

Delsys HPF datasets can become difficult to process when a study contains multiple acquisition layouts, nested folders, inconsistent filenames, EMG-only sensors, accelerometer-only sensors, or sensors that record both EMG and 3-axis acceleration. A conversion script that hard-codes one experiment can silently assign the wrong labels to another recording.

This application separates the workflow into four explicit steps:

1. **Discover** files using configurable filename and folder rules.
2. **Describe** the expected sensor order with a reusable 16-row configuration.
3. **QC** every HPF stream by observed sampling rate and expected stream order.
4. **Convert** only recordings that pass QC, without modifying or overwriting source data.

Study names, task names, muscle names, folder structures, and file keywords live in user-created configuration files rather than in the application code.

## Main features

- Recursive or single-folder `.hpf` discovery
- Filename and path include/exclude filters
- `Match ANY` or `Match ALL` filename rules
- Up to 16 ordered sensor definitions
- Sensor modes: `Ignore`, `EMG only`, `ACC only`, `EMG + ACC`
- User-defined EMG/ACC sampling frequencies and tolerances
- Stream-by-stream QC against the configured stream order
- Optional deep QC for empty or unequal-length signals
- Reusable MATLAB `.mat` configuration profiles
- Separate tab-delimited EMG and ACC outputs
- Time columns generated from observed sampling rates
- Timestamped QC summary and stream-audit CSV reports
- Conversion metadata sidecars for provenance and reproducibility
- Optional preservation of source-folder structure
- Output-tree exclusion during recursive scans
- Existing output files are never overwritten

## Requirements

- **Windows**
- **MATLAB** with `uifigure` and .NET support
- **Delsys EMGworks / MATLAB Conversion Library** containing `HPF.dll`
- Read access to source `.hpf` recordings
- Write access to a separate output directory

The Delsys `HPF.dll` is **not distributed in this repository**. A common installation path is:

```text
C:\Program Files (x86)\Delsys, Inc\EMGworks\Matlab Conversion Library\HPF.dll
```

Your installation may differ. Use the GUI's **Browse...** control to select the correct library.

Signal Processing Toolbox and App Designer are not required for the current workflow.

See [Installation](docs/INSTALLATION.md) for detailed setup.

## Quick start

1. Clone or download this repository.
2. Open MATLAB on the Windows computer with the Delsys conversion library installed.
3. Make the repository the current MATLAB folder or add it to the MATLAB path.
4. Run:

```matlab
Delsys_HPF_Converter_QC_GUI
```

5. Select `HPF.dll`.
6. Choose the input root containing HPF recordings.
7. Choose a different output root.
8. Configure filename/folder filters as needed.
9. Set expected EMG/ACC sample rates and tolerances.
10. Build the ordered channel map.
11. Click **Scan Files**.
12. Click **Run QC**.
13. Inspect failures and stream audits.
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

Example configuration:

| Order | Label | Sensor Type |
|---:|---|---|
| 1 | Head | ACC only |
| 2 | LeftMuscle | EMG + ACC |
| 3 | RightMuscle | EMG + ACC |

Expected stream sequence:

```text
HeadX, HeadY, HeadZ,
LeftMuscle EMG, LeftMuscleX, LeftMuscleY, LeftMuscleZ,
RightMuscle EMG, RightMuscleX, RightMuscleY, RightMuscleZ
```

### Critical interpretation rule

**Sampling-rate QC can help establish whether a stream behaves like EMG or ACC. It cannot independently prove the anatomical identity of the sensor.**

A PASS means the file is consistent with the **configuration supplied by the user**. It does not prove electrode placement, anatomical placement, calibration, signal quality, or physiological validity. Always validate the channel map against the acquisition setup used during collection.

## Configuration profiles

The GUI can save the current setup as a portable MATLAB `.mat` configuration containing:

- input/output settings;
- recursive-search preference;
- filename and folder filters;
- expected EMG/ACC sampling rates;
- sample-rate tolerances;
- QC options;
- channel map;
- software name/version;
- author/contact metadata;
- configuration timestamp.

This allows one application to support multiple acquisition layouts without rewriting MATLAB code.

## QC logic

### Standard QC

For each HPF file, the application:

1. reads every stream's sampling rate;
2. classifies streams as `EMG`, `ACC`, or `UNEXPECTED` using configured rates/tolerances;
3. builds the expected stream sequence from the channel map;
4. compares actual and expected stream counts;
5. compares observed and expected signal types at every stream position;
6. records a PASS/FAIL result and a stream-level audit.

### Deep QC

When enabled, Deep QC additionally verifies that:

- expected streams return samples;
- all EMG streams have equal sample counts;
- all ACC streams have equal sample counts.

See [QC & Validation](docs/QC_AND_VALIDATION.md).

## Outputs

For a source file such as:

```text
recording.hpf
```

the application may create:

```text
recording_EMG.txt
recording_ACC.txt
recording_ConversionMetadata.txt
```

QC reports are written to an output `QC_Reports` folder. Conversion metadata records software version, author/contact, conversion time, source path, configured and observed rates, expected stream count, and generated output paths.

See [Output Formats](docs/OUTPUT_FORMATS.md).

## Data safety

The application is designed around a conservative research-data workflow:

- source `.hpf` files are read, not rewritten;
- input and output roots must be different;
- recursive scans exclude the configured output tree;
- existing required outputs cause a source recording to be skipped;
- conversion is blocked until QC has been run for the current configuration;
- changing the configuration invalidates previous QC.

Keep original HPF recordings in protected storage and test new configurations on a small subset before batch conversion.

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

Delsys, Trigno, EMGworks, and related names are trademarks or products of their respective owners. This project is an independent MATLAB utility and is not presented as an official Delsys product.

Users must obtain the appropriate Delsys software/library through their own installation and licensing arrangements.

## Citation

If you use this software in academic or research work, please cite it using [`CITATION.cff`](CITATION.cff).

## Author

**Vinay Shankar**  
**vinay@tfaworld.org**  
**https://tfaworld.org/**

## License

This project is released under the **MIT License**. See [LICENSE](LICENSE).

Copyright © 2026 **Vinay Shankar**. See [COPYRIGHT.md](COPYRIGHT.md) for attribution and trademark notes.
