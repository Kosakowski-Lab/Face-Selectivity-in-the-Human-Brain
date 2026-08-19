# =============================================================================
# load_fROI_data.R
# -----------------------------------------------------------------------------
# Assembles the long-format fROI dataset used by the manuscript analyses.
#
# The 2026-07 re-run (which fixed the lh/rh hemisphere bug and switched to
# named parcels) split the data into two files, and for the volume/MNI ROIs it
# did NOT include the dyLoc face localizer:
#
#   * surface (cortical) fROIs ...... gss_fROI_dyloc_FvO_allExps_20260728.csv
#       - roi values are named parcels with a ".label" suffix (e.g. "L-FFA.label")
#       - includes the dyLoc localizer
#   * volume  (subcortical) ROIs .... gss_fROI_dyloc_FvO_allExps_MNI_20260727.csv
#       - roi values are anatomical names (e.g. "L-amygdala")
#       - does NOT include dyLoc
#
# Subcortical dyLoc is therefore grafted in from the OLD combined file
# (data/OLD/gss_fROI_allExps.csv). This is valid because:
#   (1) the lh/rh bug did not affect the volume/MNI extraction (confirmed), and
#   (2) in the old files the long "betas" equal the independent "indBeta" that
#       the face-selectivity model uses (verified row-for-row).
#
# Returns a data.frame with columns:  group, experiment, subject, roi, condition, betas
# Casing is harmonized to the new convention (experiment "dyLoc"; dyLoc
# conditions capitalized: Faces / Bodies / Objects / Scenes / Scrambled).
#
# The raw `roi` column is left untouched; each analysis script maps it to
# display names via its own rename_surface_rois().
# =============================================================================

if(!require("dplyr")) {install.packages("dplyr"); require ("dplyr")}

load_fROI_data <- function(dataDir) {

  # -- new data from this re-run ----------------------------------------------
  surfDF <- read.csv(file = paste0(dataDir, 'gss_fROI_dyloc_FvO_allExps_20260729.csv'))
  mniDF  <- read.csv(file = paste0(dataDir, 'gss_fROI_dyloc_FvO_allExps_MNI_20260727.csv'))

  # authoritative subcortical / volume ROI set (defined by the MNI file)
  subcortical_rois <- unique(mniDF$roi)

  # -- graft subcortical dyLoc from the OLD combined file ---------------------
  # (the re-run did not extract dyLoc for the volume ROIs; the hemisphere bug
  #  did not touch the volume extraction, so the old values are valid here)
  oldDF <- read.csv(file = paste0(dataDir, 'OLD/gss_fROI_allExps.csv'),
                    fileEncoding = "UTF-8-BOM")
  subDyloc <- oldDF %>%
    filter(experiment == "dyloc", roi %in% subcortical_rois) %>%
    mutate(
      experiment = "dyLoc",
      condition  = recode(condition,
                          faces = "Faces", bodies = "Bodies", objects = "Objects",
                          scenes = "Scenes", scrambled = "Scrambled")
    )

  # -- combine ----------------------------------------------------------------
  keep <- c("group", "experiment", "subject", "roi", "condition", "betas")
  allfROIdata <- bind_rows(surfDF[keep], mniDF[keep], subDyloc[keep])

  # -- report so the assembly is auditable ------------------------------------
  message("load_fROI_data: assembled ", nrow(allfROIdata), " rows")
  message("  surface (cortical) file : ", nrow(surfDF), " rows, ",
          length(unique(surfDF$roi)), " ROIs")
  message("  MNI (subcortical) file  : ", nrow(mniDF), " rows, ",
          length(unique(mniDF$roi)), " ROIs")
  message("  grafted subcortical dyLoc: ", nrow(subDyloc), " rows, ",
          length(unique(subDyloc$roi)), " ROIs, ",
          length(unique(subDyloc$subject)), " subjects")
  message("  experiments: ", paste(sort(unique(allfROIdata$experiment)), collapse = ", "))

  return(allfROIdata)
}
