# Validation Checklist for a New Acquisition Configuration

**Author:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

Use this checklist before batch-converting a new sensor layout, hardware setup, task family, or sampling-rate configuration.

## Acquisition documentation

- [ ] I know the physical sensor order used during collection.
- [ ] I know which sensors were EMG-only.
- [ ] I know which sensors were ACC-only.
- [ ] I know which sensors recorded EMG + 3-axis ACC.
- [ ] I know the expected EMG sampling frequency.
- [ ] I know the expected ACC sampling frequency.
- [ ] I have identified any sessions collected under a different configuration.

## Configuration setup

- [ ] Input root points to the intended source tree.
- [ ] Output root is separate from the source tree.
- [ ] Recursive search is set appropriately.
- [ ] Include/exclude filename rules select the intended files.
- [ ] Include/exclude folder rules select the intended folders.
- [ ] Sampling rates and tolerances are based on verified acquisition settings.
- [ ] Sensor labels are entered in original HPF order.
- [ ] Unused channel rows are `Ignore`.
- [ ] Configuration is saved with a descriptive name.

## Representative-file QC

- [ ] Scan finds the expected representative HPF file.
- [ ] Total observed stream count equals expected stream count.
- [ ] Every stream is classified as expected.
- [ ] Stream audit order matches acquisition documentation.
- [ ] Deep QC passes or any failure has been investigated.
- [ ] I have manually inspected selected converted EMG/ACC signals.

## Batch-run safeguards

- [ ] Original HPF data are backed up/protected.
- [ ] Output directory is correct.
- [ ] A small test batch succeeded before the full batch.
- [ ] QC reports are retained.
- [ ] The configuration `.mat` is retained with the derived dataset.
- [ ] Software version is recorded.
- [ ] Failed files are reviewed rather than forced through.

## Interpretation reminder

A PASS verifies consistency with the supplied configuration. It does not independently verify anatomical placement, electrode placement, task performance, signal quality, calibration, or physiological validity.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
