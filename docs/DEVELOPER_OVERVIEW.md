# Developer Overview

**Author / Maintainer:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

## Architecture

The public application is intentionally implemented as a single MATLAB function file:

```text
Delsys_HPF_Converter_QC_GUI.m
```

This minimizes deployment complexity: no App Designer `.mlapp` project is required.

## Major components

### Application metadata

Central constants define:

- application name;
- version;
- author;
- email;
- website;
- copyright.

These values are propagated into the GUI, saved configurations, QC reports, and conversion metadata.

### UI state

The GUI maintains an in-memory `state` structure containing discovered files, DLL load state, QC fingerprint, and last QC report.

### File discovery

MATLAB `dir` is used to search `.hpf` files either directly or recursively. User-defined include/exclude rules are applied to filenames and folder paths. The configured output tree is excluded from source discovery.

### Expected-stream builder

The channel map is expanded into an expected linear stream sequence:

- `EMG only` -> one EMG stream;
- `ACC only` -> X/Y/Z ACC streams;
- `EMG + ACC` -> EMG followed by X/Y/Z ACC;
- `Ignore` -> no streams.

### QC engine

Sampling rates from `GetAllSampleRates` are classified against configured frequency windows. Observed stream types are compared position-by-position with the expected sequence.

Deep QC optionally calls `GetData` and checks nonzero/equal within-class lengths.

### Conversion engine

After a valid QC fingerprint is established, passed files are read through `HPF.HPFReader`, split by expected signal type, and exported separately with independent time vectors.

### Safety model

- Source HPF files are never written.
- Input/output roots must differ.
- Existing outputs block conversion for the affected source file.
- Configuration changes invalidate prior QC.

## Public-code design rules

Core code should remain acquisition-agnostic. Do not add hard-coded study names, participant conventions, muscle lists, institutional drive paths, or task-specific sampling rates to the application.

If a workflow can be represented by configuration, it belongs in a configuration profile or documentation example rather than core code.

## Future extension ideas

Potential additions that preserve the design include:

- more than two signal classes if HPF metadata support warrants it;
- user-configurable ACC axis naming;
- configuration schema version migration;
- automated unit tests using mocked HPF reader objects;
- optional checksum/provenance recording;
- GUI preview plots for selected streams;
- packaged MATLAB app distribution while retaining the single-file source version.

Any extension should preserve the conservative no-overwrite and no-anatomical-inference principles.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
