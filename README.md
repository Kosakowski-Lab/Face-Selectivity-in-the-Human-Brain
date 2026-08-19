# 31-Face-Selective-Regions

## Face-selective regions and their responses across social tasks

Code and data for the fMRI study of face-selective functional regions of interest
(fROIs) and how they respond across a battery of social-perception and
social-cognition experiments.

The repository has two parts, run in sequence:

```
raw / preprocessed fMRI
        │
        ▼
┌──────────────────────────┐   defines face-selective fROIs (group-constrained
│   mriDataProcessing/      │   subject-specific overlap analysis) and extracts
│   (MATLAB + shell, HPC)   │   each subject's response in every fROI × condition
└──────────────────────────┘
        │  fROI beta tables (dataOutputs/*.csv)
        ▼
┌──────────────────────────┐   identifies which fROIs are face-selective and
│   statisticalAnalyses/    │   tests their responses across all experiments;
│   (R)                     │   produces the manuscript tables and figures
└──────────────────────────┘
        │
        ▼
manuscript tables & figures
```

---

## Contents

| Folder | Language | What it does | Start here if… |
|---|---|---|---|
| [`mriDataProcessing/`](mriDataProcessing/README.md) | MATLAB + shell (FreeSurfer/FSL, SLURM) | fMRI → face-selective fROIs → per-subject fROI beta tables | you want to reproduce the imaging pipeline (needs an HPC/FreeSurfer/FSL environment) |
| [`statisticalAnalyses/`](statisticalAnalyses/README.md) | R | fROI betas → face-selectivity tests, planned contrasts, and all supplementary tables/figures | you want to reproduce the statistics and figures (runs on a laptop) |

Each folder has its own README with setup, dependencies, and run order.

**Most users should start with `statisticalAnalyses/`** — it begins from the
extracted beta tables and reproduces the reported results in R without the imaging
software stack. `mriDataProcessing/` is provided for full transparency of how the
fROIs and betas were derived.

## Paths

All machine-specific paths have been removed. In `mriDataProcessing/`, paths are
placeholders of the form `/PATH/TO/...` to set for your environment. In
`statisticalAnalyses/`, set the single empty `workDir` variable at the top of each
R script to the folder's location.

## Handoff between the two parts

`mriDataProcessing/dataOutputs/` contains the extracted fROI beta CSVs. The same
tables (current versions) are provided in `statisticalAnalyses/data/`, which is
what the R scripts read.

---

<!-- Add citation, authors, license, and OSF/DOI link here before sharing. -->
