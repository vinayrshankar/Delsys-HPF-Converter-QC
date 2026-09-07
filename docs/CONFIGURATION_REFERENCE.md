# Configuration Reference

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

A saved configuration is the central reusable unit of this application. It describes **where to search, which files to include, how streams should be classified, and how the HPF stream order should be labeled**.

## Setup fields

### Delsys HPF.dll

Path to the Delsys MATLAB Conversion Library DLL.

### Input root folder

Top-level folder to scan for `.hpf` files.

### Output root folder

Destination for converted files, metadata, and QC reports. It must differ from the input root.

### Search subfolders recursively

When enabled, searches every nested subfolder beneath the input root.

### Preserve source folder structure in output

When enabled, the relative input folder structure is recreated beneath the output root. This minimizes filename collisions and preserves study organization.

## File rules

### Include filename keywords

Case-insensitive terms that must appear in the filename.

Terms may be separated by commas or semicolons.

### Match ANY / Match ALL

- `Match ANY`: filename is retained if any include keyword matches.
- `Match ALL`: filename is retained only if all include keywords match.

### Exclude filename keywords

If any exclusion term occurs in the filename, the file is omitted.

### Include folder/path keywords

If provided, at least one term must occur somewhere in the containing folder path.

### Exclude folder/path keywords

If any term occurs in the folder path, the file is omitted.

## Sampling-rate rules

### Expected EMG sample rate

Reference value used to classify an HPF stream as EMG.

### EMG tolerance

A stream is considered EMG when:

```text
abs(observed_rate - expected_EMG_rate) <= EMG_tolerance
```

### Expected ACC sample rate

Reference value used to classify a stream as accelerometer.

### ACC tolerance

A stream is considered ACC when:

```text
abs(observed_rate - expected_ACC_rate) <= ACC_tolerance
```

### Fail QC on unexpected sample rates

When enabled, streams outside both configured windows contribute to a QC failure.

### Deep QC

Reads stream data and checks for empty/unequal stream lengths by signal class.

## Channel map

There are up to 16 ordered sensor rows.

### Label

A user-defined sensor/anatomical name such as:

```text
Head
LeftTA
Sensor01
TrunkRight
```

The public application does not impose any anatomical vocabulary.

### Sensor Type

#### Ignore

No expected HPF streams are generated from the row.

#### EMG only

Expected sequence contribution:

```text
Label
```

#### ACC only

Expected sequence contribution:

```text
LabelX, LabelY, LabelZ
```

#### EMG + ACC

Expected sequence contribution:

```text
Label, LabelX, LabelY, LabelZ
```

## Stream-order assumption

The application assumes the channel map describes the HPF streams **in their original order**. It does not search for a muscle name inside the HPF file and does not infer anatomy from signal characteristics.

Example:

| Row | Label | Type |
|---:|---|---|
| 1 | Ref | ACC only |
| 2 | A | EMG + ACC |
| 3 | B | EMG only |

Expected stream positions are:

1. RefX — ACC
2. RefY — ACC
3. RefZ — ACC
4. A — EMG
5. AX — ACC
6. AY — ACC
7. AZ — ACC
8. B — EMG

If the actual sensor wiring/order differs, a file may still have the right **types** but the wrong **anatomical labels**. Validate acquisition order independently.

## Saved MAT structure

The configuration contains fields for application provenance and user settings, including:

```matlab
config.softwareName
config.softwareVersion
config.author
config.email
config.website
config.configurationGeneratedAt
config.dllPath
config.inputRoot
config.outputRoot
config.recursive
config.preserveFolders
config.includeFileKeywords
config.includeFileMode
config.excludeFileKeywords
config.includeFolderKeywords
config.excludeFolderKeywords
config.emgFs
config.emgTol
config.accFs
config.accTol
config.failUnexpected
config.deepQC
config.channelMap
```

Author/contact provenance is embedded as:

```text
Vinay Shankar
vinay@tfaworld.org
https://tfaworld.org/
```

## Configuration strategy for multiple layouts

Create a separate configuration whenever any of these change materially:

- sensor count;
- sensor order;
- EMG-only vs EMG+ACC mode;
- ACC-only reference sensors;
- sampling frequency;
- task file-selection rules.

Do not try to make one permissive configuration cover incompatible acquisition layouts merely by increasing sampling-rate tolerance or ignoring extra streams.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
