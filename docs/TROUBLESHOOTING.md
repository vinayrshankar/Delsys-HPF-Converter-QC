# Troubleshooting

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

## `HPF.dll was not found`

The DLL path in the Setup tab is incorrect or Delsys conversion components are not installed.

**Action:** locate `HPF.dll` on the computer and select it with **Browse...**.

## `Could Not Load HPF.dll`

Possible causes include:

- invalid/corrupt DLL;
- incompatible Delsys installation;
- Windows/.NET loading problem;
- dependent Delsys components missing.

Record the full MATLAB error and confirm the Delsys conversion library works on that workstation.

## Scan returns zero files

Check:

- input root exists;
- recursive search is enabled if files are nested;
- files really use `.hpf` extension;
- include filename terms are not too restrictive;
- include folder terms match actual paths;
- exclusion rules are not removing everything.

Temporarily clear all filters and rescan.

## Too many files are discovered

Add filename/folder filters. Common strategies:

- include task keywords;
- exclude `backup`, `archive`, `copy`, or old-analysis trees;
- set a more specific input root.

## QC reports `Expected N streams, found M`

The channel map does not represent that recording's acquisition layout, or the recording genuinely has a different sensor configuration.

Do not force it to pass. Determine the actual acquisition setup and create a second configuration if necessary.

## QC reports unexpected sample rates

Confirm the stream's actual acquisition/export configuration. Some datasets legitimately use different frequencies.

Create a dedicated configuration using the verified rate. Avoid using very large tolerances simply to make the file pass.

## QC says correct EMG/ACC types but labels may be wrong

This is expected if the anatomical acquisition order is unverified. Sampling frequency identifies signal class, not muscle identity.

Compare the channel order against acquisition notes/Delsys setup.

## Deep QC reports unequal EMG lengths

One or more EMG streams returned a different number of samples. The application refuses to silently truncate or pad them.

Inspect the HPF file and acquisition history. If alignment correction is scientifically justified, perform it in a separate documented preprocessing step rather than inside raw conversion.

## Deep QC reports unequal ACC lengths

Same principle as EMG: the application does not silently reshape raw streams.

## Output already exists

The application is designed never to overwrite. Choose a new output root or deliberately manage the old derived output after confirming backups.

## MATLAB table variable names differ from labels

MATLAB requires valid, unique variable names. Spaces/punctuation may be removed and duplicate names made unique. The intended label remains represented as closely as MATLAB allows.

## Network path is unavailable

Confirm the drive/share is mounted and readable in Windows Explorer and MATLAB. Saved configuration paths may need updating when a mapped drive letter changes.

## GUI does not open

Confirm your MATLAB release supports `uifigure` and related modern UI components. Run the file directly from the MATLAB command window to capture the full error.

## Reporting a bug

Send the following to **vinay@tfaworld.org**:

- MATLAB version;
- Windows version;
- application version;
- complete error text and line number;
- configuration details excluding sensitive data;
- expected stream layout;
- observed sampling-rate sequence if available.

Project website: **https://tfaworld.org/**
