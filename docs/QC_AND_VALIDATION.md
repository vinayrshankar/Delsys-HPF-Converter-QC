# QC and Validation Guide

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

## Purpose of QC

The QC system is intended to prevent a common conversion error: exporting HPF streams under a channel map that does not match the acquisition configuration.

It checks **structural consistency**, not physiological signal quality.

## Standard QC sequence

For each HPF recording:

1. Open the file using Delsys `HPF.HPFReader`.
2. Retrieve all stream sampling rates.
3. Classify each stream as `EMG`, `ACC`, or `UNEXPECTED` using the configured rates/tolerances.
4. Build the expected stream sequence from the 16-row channel map.
5. Compare total stream count.
6. Compare observed and expected type at each stream position.
7. Record PASS/FAIL and a stream-level explanation.

## What PASS means

PASS means:

- the stream count matches the configured expected count;
- each observed stream falls into the configured EMG/ACC sampling-rate category expected at that position;
- no configured fatal unexpected-rate condition occurred;
- if Deep QC is enabled, the expected streams could be read and within-class sample counts were consistent.

## What PASS does **not** mean

PASS does not prove:

- the electrode was on the intended muscle;
- left/right sensors were not swapped;
- the channel label entered by the user is anatomically correct;
- the signal has good signal-to-noise ratio;
- electrodes maintained contact;
- accelerometers were oriented correctly;
- the task was performed correctly;
- calibration was correct;
- timestamps align with another acquisition device;
- physiological data are scientifically valid.

## Sampling frequency as a signal-type check

Sampling rate is useful because EMG and accelerometer streams are often acquired/exported at different frequencies. The application therefore uses configured frequency windows as a classification rule.

However, sampling rates can differ across acquisition setups. A lower-frequency ACC configuration can be legitimate. If you encounter a repeated alternative rate:

1. confirm it in the acquisition/software setup;
2. create a separate configuration;
3. enter that configuration's correct ACC rate and tolerance;
4. rerun QC.

Do not classify a novel rate as ACC solely because it is numerically related to a previously observed rate.

## Deep QC

Deep QC checks data availability/length consistency after structural classification.

It currently checks:

- zero-sample streams;
- unequal EMG sample counts;
- unequal ACC sample counts.

It intentionally does not resample, trim, pad, filter, rectify, normalize, or otherwise alter signal values.

## Stream audit table

Each row reports:

- stream index;
- observed sample rate;
- observed type;
- expected sensor;
- expected signal type;
- output label;
- PASS/FAIL match;
- explanatory comment.

Use this table to diagnose exactly where a configuration diverges from a file.

## Typical failure patterns

### More streams than expected

Possible explanations:

- an extra sensor was enabled;
- a sensor switched from EMG-only to EMG+ACC;
- an ACC-only reference sensor was added;
- wrong configuration loaded.

### Fewer streams than expected

Possible explanations:

- a sensor was disabled;
- accelerometry was not recorded for a sensor;
- wrong configuration loaded;
- file is incomplete.

### Correct count, wrong order

Possible explanations:

- acquisition sensor order changed;
- map order is wrong;
- one sensor type was configured incorrectly.

### Unexpected sampling rate

Possible explanations:

- valid alternative acquisition setting;
- different hardware/software export mode;
- file is not part of the intended acquisition configuration;
- corrupt/unusual stream metadata.

## Recommended validation before publication-quality use

For every new acquisition configuration:

1. choose one known-good HPF file;
2. document the physical sensor order from acquisition notes/software;
3. retrieve/inspect stream frequencies;
4. configure the channel map;
5. run QC;
6. verify expected stream labels position-by-position;
7. convert the test file;
8. visually inspect selected EMG/ACC channels using your normal analysis environment;
9. save the configuration;
10. then batch-process the matching file family.

## Reproducibility record

Archive the configuration `.mat`, QC summary, stream audit, software version, and conversion metadata with the derived dataset.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
