# MRI Data Processing — defining face-selective fROIs and extracting responses

MATLAB + shell pipeline that goes from preprocessed fMRI data to the
per-subject functional region-of-interest (fROI) beta values used in the
manuscript. It defines face-selective regions with a group-constrained
subject-specific (GSS) overlap analysis, converts them to parcels/labels, and
extracts each subject's response (beta) in every fROI for every task condition.

The beta tables produced here (`dataOutputs/`) are the **input** to the sibling
`final-analyses/` folder.

> This pipeline was run on an HPC cluster (SLURM) with FreeSurfer and FSL. The
> `.sh` scripts contain `#SBATCH` directives and call FreeSurfer/FSL binaries, so
> reproducing the full pipeline requires that environment. The code is shared for
> transparency; most users will start from the extracted betas in
> `final-analyses/`.

---

## 1. Set the two paths

Every hardcoded path has been replaced with the placeholder `/PATH/TO/...`.
Before running anything, set them to your environment:

- **`/PATH/TO/faces`** — the study root (where the fMRI sessions, analyses, and
  `code/` live). In the `.m` files this is the `startDir` variable; in the `.sh`
  scripts it appears in `wkdir=`, `cd`, and `#SBATCH -o/-e` log paths.
- **`/PATH/TO/brains/subjAnats`** — the FreeSurfer `SUBJECTS_DIR` (subject
  anatomicals / recon-all output). Appears as `SUBJECTS_DIR`, `brainDir`,
  `mniDir`, etc.
- A few files also reference `/PATH/TO/FreeSurferColorLUT_edits.txt` (a customized
  FreeSurfer color lookup table) and, in `studyScript.m`, an empty `parcDir` you
  set to your subcortical-parcel folder.

Fastest way to adapt: find-and-replace `/PATH/TO/faces` and `/PATH/TO/brains`
across `code/` with your real paths.

## 2. Software

FreeSurfer (surface analyses, `recon-all`, `mri_*`, label tools), FSL
(`fslmaths` for the subcortical parcels), MATLAB (with the FreeSurfer MATLAB
tools on the path), and a SLURM scheduler for the `.sh` jobs.

---

## 3. Pipeline (see `studyScript_20260726.m`)

`studyScript_20260726.m` is the master script; it documents the full order of
operations. In brief:

1. **Preprocess** fMRI runs — `run_run_preprocess.sh` → `run_preprocess.sh`.
2. **Timepoint-exclusion (motion) files** — `makeImpFiles_dyLoc.m`, `makeImpFiles_nonDyLoc.m`.
3. **Single-subject GLMs** — `setAnalyses_dyLoc_sm4.m` / `setAnalyses_nonDyLoc_sm4.m`
   set up the models; the `run_dyloc_allCons_*.sh` and `singleSubjectGLM_*.sh`
   scripts fit them per subject/experiment (dyLoc, gesture, eib1, tom, …).
4. **Random-effects + split-half** — `rfx_splitHalf.m`, `findSplitHalf.m`,
   `setAnalyses_dyLoc_sm4_splitHalf.m`, `run_dyloc_faces.sh`, `run_dyloc_allCons.sh`.
5. **GSS overlap → parcels (surface)** — `getZmaps_4overlap.m`, `gssOverlap.m`
   (top-N% overlap maps), `group_cluster_summary_4_topN.m`, `make_annot_file.m`,
   `make_annot_handEdits.m` (parcels = top 10% of vertices/subject at ≥45% overlap,
   with hand-drawn splits; parcels need ≥100 vertices).
6. **fROI beta extraction (surface)** — `annot2subjLabels_20240625.m` warps labels
   to each subject; `run_gss_fROI_allExps_20260726.m` selects voxels on odd runs
   and extracts betas (even runs for dyLoc, all runs for other experiments).
7. **Subcortical / volume stream** — `getZmaps_4overlap_volume.m`,
   `gssOverlap_volume.m`, `group_cluster_summary_4_topN_vol.m`, `make_vol_rois.m`,
   `make_mni_parcels.m`, then MNI-space GLMs (`run_glm_MNI_20250916.m`) and volume
   fROI extraction (`run_gss_fROI_volume.m`, `run_gss_fROI_allExps_volume_20260726.m`).

---

## 4. Folder structure

```
fMRI-data-processing/
├── studyScript_20260726.m   master script (pipeline order, top to bottom)
├── code/                    all analysis functions and SLURM job scripts (.m, .sh)
├── dataOutputs/             extracted fROI beta tables (feed statisticalAnalyses/)
│   ├── gss_fROI_dyloc_FvO_allExps_20260728.csv      cortical (surface) fROI betas
│   ├── gss_fROI_dyloc_FvO_allExps_MNI_20260727.csv  subcortical (MNI) fROI betas
│   └── gss_fROI_dyloc_FvO_allExps_allBetas_interactionRSA_28-Apr-2026.csv
└── final_rois/              final fROI parcels / label files
```

---

## 5. Output → next step

The CSVs in `dataOutputs/` (one row per subject × fROI × condition) are the
starting point for the R analyses in `../final-analyses/`, which identify
the face-selective fROIs and test their responses across all experiments.

