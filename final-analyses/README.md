# Statistical Analyses — face-selective fROI responses across social tasks

R analysis pipeline for the functional region-of-interest (fROI) analyses in the
manuscript. Starting from extracted fROI beta values (one value per subject ×
fROI × condition), these scripts identify face-selective regions, test their
responses across a battery of social-perception and social-cognition experiments,
and produce the manuscript's supplementary tables and figures.

> The fROIs themselves (group-constrained subject-specific parcels) were defined
> by the MATLAB pipeline in the sibling `fMRI-data-processing/` folder. This folder
> begins from the resulting per-subject fROI beta values (in `data/`).

---

## 1. Set up

1. Install R (≥ 4.1) and the required packages:

   ```r
   install.packages(c("tidyverse", "lmerTest", "lme4", "dplyr", "tidyr",
                      "emmeans", "pbkrtest", "psych", "lattice",
                      "ggplot2", "ggdendro", "dendextend",
                      "officer", "flextable", "magrittr", "sjPlot"))
   ```

2. In **each** script you run, set the `workDir` variable at the top to the path
   of this `final-analyses` folder. It is left blank on purpose:

   ```r
   workDir <- ''   # e.g. '~/Downloads/final-analyses/'
   ```

   (`statistics_allfROIs_20260811.R` and `make_TableS1.R` expect a **trailing
   slash**; `barPlots_20260728.R` expects **no** trailing slash — see the comment
   on each line.)

All other paths (`data/`, `results/`, `plots/`) are derived from `workDir`.

---

## 2. Folder structure

```
final-analyses/
├── code/
│   ├── statistics_allfROIs_20260811.R   main analysis (run this first)
│   ├── load_fROI_data.R                 helper: assembles the data frame (sourced by the others)
│   ├── barPlots_20260728.R              per-fROI condition bar plots
│   └── make_TableS1.R                   participant-count table (Table S1)
├── data/
│   ├── gss_fROI_dyloc_FvO_allExps_20260729.csv      cortical (surface) fROI betas, all experiments
│   ├── gss_fROI_dyloc_FvO_allExps_MNI_20260727.csv  subcortical (MNI/volume) fROI betas
│   ├── subj_dyloc_counts_20260729.csv               per-subject dynamic-localizer run counts (Table S1)
│   ├── subj_exp_counts_20260729.csv                 per-subject experiment participation (Table S1)
│   └── OLD/gss_fROI_allExps.csv                     source for the grafted subcortical dyLoc betas (see note below)
├── results/        (tables are written here; contrasts/ holds Tables S5–S29)
└── plots/          (figures are written here)
```

---

## 3. What to run

| Script | Produces |
|---|---|
| `statistics_allfROIs_20260811.R` | Face-selectivity designations; `faceSelect_statistics*.txt`; Table S3 (face selectivity), Table S4 (experiment ANOVAs), Tables S5–S29 (per-region planned contrasts, in `results/contrasts/`); hierarchical-clustering dendrogram (`plots/hierarchicalClustering.png`) |
| `make_TableS1.R` | Table S1 (participant counts per condition per dataset) |
| `barPlots_20260728.R` | Per-fROI condition bar plots (`plots/roiPlots/`, `plots/roiPlots_normed/`) |

`statistics_allfROIs_20260811.R` and `barPlots_20260728.R` both `source()`
`load_fROI_data.R`, so it does not need to be run on its own.

---

## 4. Analysis notes

- **Face-selective fROIs** are defined by a one-tailed test on the dynamic face
  localizer: a region is "selective" when the response to Faces is significantly
  greater than the response to fixation (i.e., baselime) and
  each of Bodies, Objects, Scenes, and Scrambled (all one-tailed p < .05).
- **Planned contrasts** (Tables S5–S29) are estimated with linear mixed models
  (`lmer(betas ~ condition + (1|subject))`) and `emmeans` contrasts; p-values are
  two-tailed. Cohen's *d* = contrast estimate / residual SD.
- **Subcortical dynamic-localizer betas** are grafted from `data/OLD/gss_fROI_allExps.csv`.
  An earlier surface labeling issue (a left/right hemisphere swap) did **not**
  affect the subcortical volume extraction, so those subcortical dyLoc values are
  taken from the earlier extraction; all cortical values and all non-dyLoc
  experiments use the current files. See `load_fROI_data.R` for the exact merge.

---

## 5. Data dictionary (fROI beta files)

Each row is one subject × fROI × condition. Key columns: `subject`, `roi`
(anatomical parcel name), `experiment`, `condition`, `betas` (GLM beta relative to
fixation baseline). `load_fROI_data.R` renames parcels to the short labels used in
the manuscript (e.g. `R-FFA`) and combines the cortical + subcortical sources.

