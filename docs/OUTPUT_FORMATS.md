# Output Formats and Provenance

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

## Signal outputs

A source HPF can generate separate tab-delimited text files:

```text
<basename>_EMG.txt
<basename>_ACC.txt
```

The application only writes a signal file if that signal type is present in the configured expected stream map.

## Time column

The first column is `Time` in seconds.

For a signal class sampled at `Fs`, time is constructed as:

```matlab
(0:n-1)' ./ Fs
```

where `n` is the sample count and `Fs` is the mean observed sampling rate across streams of that class.

EMG and ACC are exported separately because they can have different sample counts and sampling frequencies.

## Channel names

Labels come from the user-defined channel map.

ACC channels append axis suffixes:

```text
SensorX
SensorY
SensorZ
```

MATLAB converts labels to valid and unique table-variable names when required. Consequently, punctuation/spaces may be normalized in the exported header.

## Conversion metadata sidecar

Each converted source file receives:

```text
<basename>_ConversionMetadata.txt
```

The sidecar includes software provenance:

```text
Software: Delsys HPF Converter + QC
Version: <version>
Author: Vinay Shankar
Website: https://tfaworld.org/
Email: vinay@tfaworld.org
```

It also records conversion timestamp, source path, configured sampling rates, observed mean sampling rates, expected stream count, and generated output paths.

## QC reports

The output root contains:

```text
QC_Reports/
```

with timestamped CSV files.

### QC summary

Contains one row per source recording, including:

- software author;
- software email;
- software website;
- software version;
- source file;
- use flag;
- QC status;
- stream count;
- EMG/ACC/unexpected counts;
- expected count;
- explanatory note.

### Stream audit

Contains one row per HPF stream with:

- source file;
- stream number;
- observed sample rate;
- observed type;
- expected sensor;
- expected type;
- output label;
- PASS/FAIL;
- comment.

## Folder preservation

If enabled, a source such as:

```text
InputRoot/Participant/Session/recording.hpf
```

is written beneath:

```text
OutputRoot/Participant/Session/
```

This is recommended for large studies because it reduces filename collisions and retains context.

## Never-overwrite behavior

Before writing, the application checks every required output. If any required file already exists, conversion for that source is skipped.

This is deliberate. The software does not silently replace derived research data.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
