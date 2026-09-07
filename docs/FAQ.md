# Frequently Asked Questions

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

## Does this modify my HPF files?

No. The application reads HPF data and writes separate derived files to the configured output root.

## Can it overwrite converted data?

The application intentionally refuses to overwrite required output files.

## Does it automatically know which muscle a stream came from?

No. The user supplies sensor/anatomical labels and stream order through the channel map. QC checks signal type/order consistency, not physical electrode identity.

## Why separate EMG and ACC files?

They often have different sampling frequencies and sample counts. Separate outputs avoid false alignment assumptions.

## Can one sensor have EMG only while another has EMG + ACC?

Yes. Each of the 16 channel rows has an independent sensor type.

## Can I have an accelerometer-only sensor?

Yes. Set that row to `ACC only`.

## Can I use more than one acquisition configuration?

Yes. Save multiple `.mat` configuration profiles. This is preferred over hard-coding study-specific logic.

## Can folder nesting vary?

Yes. Recursive search can scan an arbitrary nested tree beneath the input root.

## Do filenames need a fixed naming convention?

No. Keywords are optional. You can search all HPF files, filter by filename, filter by folder path, or combine rules.

## Are the default sample rates universal Delsys rates?

No. They are editable starting values. Verify the rates used in your own acquisition/export setup.

## What if accelerometer sampling rate changed midway through a study?

Create a separate configuration for the second acquisition configuration and QC it independently.

## Does PASS mean the data are scientifically good?

No. PASS means the HPF structure matches the supplied configuration. It does not assess physiological validity, electrode placement, artifact, calibration, or task performance.

## Do I need Signal Processing Toolbox?

Not for the current HPF discovery/QC/export workflow.

## Can I use it on macOS or Linux?

The current implementation depends on the Windows Delsys `HPF.dll` and MATLAB .NET loading, so the supported workflow is Windows.

## Who maintains the software?

**Vinay Shankar**  
**vinay@tfaworld.org**  
**https://tfaworld.org/**
