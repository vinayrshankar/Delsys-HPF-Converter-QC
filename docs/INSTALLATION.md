# Installation and Software Requirements

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

## 1. What you need

### Operating system

Use **Windows**. The application relies on the Delsys `HPF.dll` and MATLAB's .NET assembly loading. The public package does not provide a macOS/Linux HPF reader.

### MATLAB

Use a current MATLAB release that supports:

- `uifigure`, `uigridlayout`, `uitable`, `uieditfield`, `uidropdown`, and related UI components;
- .NET assembly loading through `NET.addAssembly`;
- tables and `writetable`.

The project does not currently require App Designer or Signal Processing Toolbox.

### Delsys conversion software

You need the Delsys EMGworks MATLAB Conversion Library containing `HPF.dll`. A commonly observed installation path is:

```text
C:\Program Files (x86)\Delsys, Inc\EMGworks\Matlab Conversion Library\HPF.dll
```

Your local path may differ. The GUI allows you to browse to the DLL.

### Data permissions

You need:

- read access to the HPF source tree;
- write access to the selected output folder.

For shared/network data, confirm the drive is mounted before MATLAB starts processing.

## 2. Install the repository

### Option A: Git clone

```bash
git clone <repository-url>
```

Open MATLAB and either make the cloned directory the current folder or run:

```matlab
addpath('path-to-repository')
```

### Option B: ZIP download

1. Download the repository ZIP.
2. Extract it to a permanent folder.
3. Open MATLAB.
4. Change MATLAB's current folder to the extracted repository or add it to the path.

## 3. Launch the GUI

Run:

```matlab
Delsys_HPF_Converter_QC_GUI
```

The window title should identify the application, version, author, and project website.

## 4. Verify HPF.dll

In the Setup tab:

1. inspect the `Delsys HPF.dll` field;
2. if the default path is wrong, click **Browse...**;
3. select the correct `HPF.dll`;
4. proceed to scanning/QC.

The DLL is actually loaded when HPF access is needed. If MATLAB cannot load it, the GUI displays the Delsys/.NET error and records it in the Log tab.

## 5. Recommended first-installation test

Do not start with an entire study.

1. Copy or point the input root to a small test folder with one known HPF file.
2. Create a separate empty output folder.
3. Enter the known acquisition channel map.
4. Run **Scan Files**.
5. Run **Run QC**.
6. Confirm the stream audit matches the acquisition configuration.
7. Convert the file.
8. Open the output text and metadata files.
9. Only then scale up to batch processing.

## 6. Network-drive considerations

The application can work with mapped drives and nested directories as long as MATLAB can see them. For example, an input root can be a study-level folder while relevant HPF files live several levels deeper.

If a mapped drive disappears or reconnects under a different drive letter, saved configurations may need their input/output paths updated.

## 7. Updating

When updating the repository:

- retain your own `.mat` configuration profiles separately;
- read `CHANGELOG.md` for changes to configuration fields or QC behavior;
- revalidate one representative HPF file after a software update before running a large batch.

## 8. Getting help

When reporting a problem, include:

- MATLAB release;
- Windows version;
- application version;
- the exact error message and line number;
- the expected sensor map;
- the stream sample-rate sequence if available;
- whether the file opens normally in Delsys software.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
