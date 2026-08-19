if(!require("tidyverse")) {install.packages("tidyverse"); require ("tidyverse")}
if(!require("lmerTest")) {install.packages("lmerTest"); require ("lmerTest")}
if(!require("lme4")) {install.packages("lme4"); require ("lme4")}
if(!require("dplyr")) {install.packages("dplyr"); require ("dplyr")}
if(!require("sjPlot")) {install.packages("sjPlot"); require ("sjPlot")}
if(!require("emmeans")) {install.packages("emmeans"); require ("emmeans")}
if(!require("pbkrtest")) {install.packages("pbkrtest"); require ("pbkrtest")}
if(!require("officer")) {install.packages("officer"); require ("officer")}
if(!require("flextable")) {install.packages("flextable"); require ("flextable")}
if(!require("tidyr")) {install.packages("tidyr"); require ("tidyr")}
if(!require("psych")) {install.packages("psych"); require ("psych")}
if(!require("lattice")) {install.packages("lattice"); require ("lattice")}
if(!require("ggplot2")) {install.packages("ggplot2"); require ("ggplot2")}
if(!require("ggdendro")) {install.packages("ggdendro"); require ("ggdendro")}
if(!requireNamespace("dendextend", quietly = TRUE)) install.packages("dendextend")  # used via dendextend:: only

# written by Heather L Kosakowski
# 2024.06.29

# ------------------------------------------------------------------------------
# ------------------------------ functions -------------------------------------
# ------------------------------------------------------------------------------

# function to compute the one-tailed p-value
one_tail_p_value <- function(estimated_beta, two_tail_p_value, face) {
  if (face) {
    if (estimated_beta > 0) {
      one_tailed_p_value <- two_tail_p_value / 2
    } else {
      one_tailed_p_value <- 1 - (two_tail_p_value / 2)
    }
  } else {
    if (estimated_beta < 0) {
      one_tailed_p_value <- two_tail_p_value / 2
    } else {
      one_tailed_p_value <- 1 - (two_tail_p_value / 2)
    }
  }
}

# function to round the p-value to the first non-zero value
round_to_first_nonzero <- function(x, n_digits = 1) {
  if (x == 0) {
    return(0)
  }
  abs_x <- abs(x)
  
  # Find the position of the first non-zero digit
  if (abs_x < 1) {
    log_val <- log10(abs_x)
    first_nonzero_pos <- floor(log_val)
    
    # Calculate digits for rounding
    digits_to_round <- abs(first_nonzero_pos) + n_digits - 1
  } else {
    # For numbers >= 1, round to n_digits after the decimal
    digits_to_round <- n_digits 
  }
  rounded_val <- round(x, digits = digits_to_round)
  return(rounded_val)
}

# function to rename the ROIs
# Cortical parcels now arrive already named with a ".label" suffix
# (e.g. "L-FFA.label"), so we simply drop the suffix. Subcortical / volume
# ROIs arrive with anatomical names and are mapped to the short labels below.
rename_surface_rois <- function(roiNames) {
  roiNames[roiNames == "dmThalamus"] <- "dmThal"
  roiNames[roiNames == "R-amygdala"] <- "R-Amyg"
  roiNames[roiNames == "L-amygdala"] <- "L-Amyg"
  roiNames[roiNames == "R-pHippocampus"] <- "R-pHipp"
  roiNames[roiNames == "L-pHippocampus"] <- "L-pHipp"
  roiNames[roiNames == "R-pallidum"] <- "R-GP"
  roiNames[roiNames == "L-pallidum"] <- "L-GP"
  roiNames[roiNames == "L-accumbens"] <- "L-VS"
  roiNames[roiNames == "R-accumbens"] <- "R-VS"
  roiNames[roiNames == "L-caudate"] <- "L-Caud"
  roiNames[roiNames == "R-caudate"] <- "R-Caud"
  roiNames[roiNames == "L-cerebellum1"] <- "L-Cerb"
  roiNames[roiNames == "R-cerebellum1"] <- "R-Cerb1"
  roiNames[roiNames == "R-cerebellum2"] <- "R-Cerb2"
  roiNames[roiNames == "R-cerebellum3"] <- "R-Cerb3"
  roiNames[roiNames == "L-ventralDC"] <- "L-VDC"
  roiNames[roiNames == "R-ventralDC"] <- "R-VDC"
  roiNames[roiNames == "L-putamen"] <- "L-Put"
  roiNames[roiNames == "R-putamen"] <- "R-Put"
  roiNames[roiNames == "sc"] <- "SC"
  # cortical surface parcels are already named; drop the ".label" suffix
  roiNames <- sub("\\.label$", "", roiNames)
  return(roiNames)
}

# this functions stores all of the ANOVA results in a table in a Word Document
create_word_table_4_anovas <- function(dfAnova, expOrder, docTitle) {
  anova_tbl <- dfAnova %>%
    mutate(
      exp = factor(exp, levels = expOrder),
      effect = factor(param, levels = c("fROI", "Condition", "fROI × Condition")),
      df = paste0(round(numDF, 0), ", ", round(denDF, 0)),
      Fval = sprintf("%.2f", fVal),
      Pval = ifelse(pVal < 0.001, "<0.001", sub("^0", "", sprintf("%.3f", pVal)))
    ) %>%
    arrange(exp, effect) %>%
    select(exp, effect, df, Fval, Pval, pVal)  # keep pVal only for styling
  
  ft <- flextable(anova_tbl) %>%
    set_header_labels(exp = "Experiment", effect = "Effect", df = "df", Fval = "F", Pval = "p") %>%
    align(j = c("exp", "effect"), align = "left", part = "all") %>%
    align(j = c("df", "Fval", "Pval"), align = "center", part = "all") %>%
    bold(i = ~ pVal < 0.05, j = "Pval", bold = TRUE) %>%
    delete_columns("pVal") %>%   # remove raw pVal from the displayed table
    merge_v(j = "exp") %>%       # merge AFTER delete_columns (else it gets reset)
    valign(j = "exp", valign = "top", part = "body") %>%
    theme_booktabs() %>%
    bold(part = "header") %>%
    fontsize(size = 10, part = "all") %>%
    font(fontname = "Garamond", part = "all") %>%
    padding(padding = 2, part = "all") %>%
    autofit()

  # zebra shading: alternate light blue / white by experiment block
  exps_in_order <- unique(as.character(anova_tbl$exp))
  for (k in seq_along(exps_in_order))
    if (k %% 2 == 1)
      ft <- bg(ft, i = which(as.character(anova_tbl$exp) == exps_in_order[k]),
               bg = "#C6D9F1", part = "body")

  doc <- read_docx() %>%
    body_add_flextable(ft) %>%
    body_set_default_section(prop_section(
      page_size    = page_size(width = 12240/1440, height = 15840/1440, orient = "portrait"),  # US Letter
      page_margins = page_mar(top = 1, bottom = 1, left = 1, right = 1)))
  savePath <- resultsDir   # set from workDir below
  print(doc, target = paste0(savePath, docTitle, ".docx"))
}

# this function computes all of the pairwise comparisons for each fROI
results_list <- function(exp, roiDF, fROIname) {
  # get the data into the correct format
  expDF <- filter(roiDF, experiment==exp)
  expLMER <- lmer(betas ~ condition + (1|subject), data=expDF)
  emmExp <- emmeans(expLMER, ~ condition)
  # 
  levels(emmExp)
  # establish the pre-planned paired comparisons
  if (exp=="mega") {
    expCons <- contrast(emmExp, list(
      "LANGvNON" = c(0.25, -.5, -.5, 0.25, 0.25, 0.25),
      "ToMvBOD" = c(-1, 0, 0, 0, 0, 1),
      "VvM" = c(0, 1, -1, 0, 0, 0),
      "PPLvOBJ" = c(0.5, 0, 0, -0.5, -0.5, 0.5)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 4
    expName <- "Auditory"
    
  } else if (exp == "plw") {
    expCons <- contrast(emmExp, list(
      "INTvNINT" = c(1, -1)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 1
    expName <- "PLWs"
    
  } else if (exp == "tva") { 
    expCons <- contrast(emmExp, list(
      "VOCvNON" = c(-1, 1)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 1
    expName <- "Vocal"
    
  } else if (exp == "tom") {
    expCons <- contrast(emmExp, list(
      "FBvFP" = c(1, -1)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 1
    expName <- "ToM Loc"

  } else if (exp == "lang2cond") {
    # levels(emmExp)
    expCons <- contrast(emmExp, list(
      "INTvALT" = c(-1, 1) 
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 1
    expName <- "Lang Loc"

  } else if (exp == "bio") {
    expCons <- contrast(emmExp, list(
      "BIOvOBJ" = c(1, 0, 0, -1, 0, 0),
      "BIOvBSCR" = c(1, -1, 0, 0, 0, 0),
      "OBJvOSCR" = c(0, 0, 0, 1, -1, 0)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 3
    expName <- "PLDs"

  } else if (exp == "eib1") {
    expCons <- contrast(emmExp, list(
      "MvF" = c(-0.5, -0.5, 0.5, 0.5, 0, 0, 0, 0),
      "PEXPvNEXP" = c(0.5, -0.5, 0.5, -0.5, 0, 0, 0, 0),
      "PPLvCRT" = c(0.25, 0.25, 0.25, 0.25, -0.25, -0.25, -0.25, -0.25),
      "GRPvAGT" = c(0, 0, 0, 0, -.5, -.5, .5, .5),
      "POSvNEG" = c(0.25, -0.25, 0.25, -0.25, 0.25, -0.25, 0.25, -0.25),
      "SUCvFAIL" = c(0, 0, 0, 0, 1, -1, 0, 0),
      "INCvEX" = c(0, 0, 0, 0, 0, 0, 1, -1)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 7
    expName <- "Emo Inf"

  } else if (exp == "gesture") {
    expCons <- contrast(emmExp, list(
      "OCCvNOT" = c(-1, 0.5, 0, 0.5, 0),
      "GESTvGRM" = c(0, 0.5, 0.5, -0.5, -0.5),
      "SPvSIL" = c(0.33, 0.33, -.5, 0.33, -0.5)
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 3
    expName <- "Gesture"

  } else if (exp == "shape") {
    expCons <- contrast(emmExp, list(
      "HELPvHIND" = c(1, -1, 0, 0),
      "AGTvPHS" = c(0.5, 0.5, 0, -1),
      "2v1" = c(0.5, 0.5, -1, 0) 
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 3
    expName <- "Shape"

  } else if (exp == "dyLoc") {
    expCons <- contrast(emmExp, list(
      "FvB" = c(-1, 1, 0, 0, 0),
      "FvO" = c(0, 1, -1, 0, 0),
      "FvS" = c(0, 1, 0, -1, 0),
      "FvSc" = c(0, 1, 0, 0, -1),
      "BvO" = c(1, 0, -1, 0, 0),
      "OvSc" = c(0, 0, 1, 0, -1) 
    ), adjust = "none", infer = c(TRUE, TRUE))
    nCons <- 6
    expName <- "DyLoc"
    
  } else {
    stop("Unknown experiment: ", exp)
  }
  # get the relevant information into an easy-to-use data frame
  dfExp <- data.frame(expCons)
  # add cohen's d to the dataframe
  dfExp$cohens_d <- dfExp$estimate / sigma(expLMER)
  # get all of the relevant information into a handy output that can be used to 
  # create the word document we are interested in
  out <- vector("list", nCons)
  for (iCon in seq_len(nCons)) {
    out[[iCon]] <- data.frame(
      fROI = fROIname,
      contrast = dfExp$contrast[iCon],
      experiment = expName,
      beta = dfExp$estimate[iCon],
      uCI = dfExp$upper.CL[iCon],
      lCI = dfExp$lower.CL[iCon],
      tVal = dfExp$t.ratio[iCon],
      df = dfExp$df[iCon],
      p = dfExp$p.value[iCon],
      d = dfExp$cohens_d[iCon])
  }
  do.call(rbind, out)
}

# this function makes a Word table for all of the results for the
# pre-planned paired comparisons
wordTable <- function(dfResults, region_order, experiment_order, contrast_order,
                      docName, savePath) {
  required_cols <- c("beta", "experiment", "contrast", "fROI", "tVal", "df", "p", "d", "lCI", "uCI")
  missing_cols <- setdiff(required_cols, names(dfResults))
  if (length(missing_cols) > 0) {
    stop("dfResults is missing these columns: ", paste(missing_cols, collapse = ", "))
  }
  dir.create(savePath, recursive = TRUE, showWarnings = FALSE)
  
  # Long format with cleaned labels
  long_tbl <- dfResults %>%
    mutate(
      experiment = factor(experiment, levels = experiment_order),
      contrast = factor(contrast, levels = contrast_order),
      fROI = as.character(fROI),
      beta_fmt = sprintf("%.2f", beta),
      t_fmt = sprintf("%.2f", tVal),
      df_fmt = sprintf("%.1f", df),
      p_txt = ifelse(p < 0.001, "<0.001", sprintf("=%.3f", p)),
      d_fmt = sprintf("%.2f", d),
      lCI_fmt = sprintf("%.1f", lCI),
      uCI_fmt = sprintf("%.1f", uCI),
      # text pieces that FOLLOW each italic symbol (beta, t, p, d)
      pre = paste0("=", beta_fmt, ", [", lCI_fmt, ", ", uCI_fmt, "]\n"),
      tt  = paste0("(", df_fmt, ")=", t_fmt, ", "),
      pp  = paste0(p_txt, ", "),
      dd  = paste0("=", d_fmt)
    ) %>%
    filter(!is.na(experiment), !is.na(contrast), !is.na(fROI)) %>%
    arrange(experiment, contrast, fROI) %>%
    distinct(experiment, contrast, fROI, .keep_all = TRUE)
  
  # pivot each text piece (and the p-value) to wide: one column per fROI
  pivot_piece <- function(colname) {
    tmp <- as.data.frame(long_tbl)[, c("experiment", "contrast", "fROI", colname)]
    names(tmp)[4] <- ".v"
    pivot_wider(tmp, names_from = fROI, values_from = .v, values_fn = first)
  }
  w_pre <- pivot_piece("pre"); w_tt <- pivot_piece("tt")
  w_pp  <- pivot_piece("pp");  w_dd <- pivot_piece("dd")
  p_tbl <- long_tbl %>%
    select(experiment, contrast, fROI, p) %>%
    pivot_wider(names_from = fROI, values_from = p, values_fn = first)
  
  # make sure every requested ROI column exists and is in order
  ensure_cols <- function(tb, fill) {
    for (roi in region_order) if (!roi %in% names(tb)) tb[[roi]] <- fill
    tb %>% select(experiment, contrast, all_of(region_order))
  }
  w_pre <- ensure_cols(w_pre, NA_character_)
  w_tt  <- ensure_cols(w_tt,  NA_character_)
  w_pp  <- ensure_cols(w_pp,  NA_character_)
  w_dd  <- ensure_cols(w_dd,  NA_character_)
  p_tbl <- ensure_cols(p_tbl, NA_real_)

  # display frame: ROI cells start empty and are filled by compose() below
  disp <- data.frame(experiment = as.character(w_pre$experiment),
                     contrast   = as.character(w_pre$contrast),
                     check.names = FALSE, stringsAsFactors = FALSE)
  for (roi in region_order) disp[[roi]] <- ""

  ft <- flextable(disp) %>%
    set_header_labels(experiment = "Experiment", contrast = "Contrast") %>%
    merge_v(j = "experiment") %>%
    align(j = c("experiment", "contrast"), align = "left", part = "all") %>%
    align(j = region_order, align = "center", part = "all") %>%
    theme_booktabs() %>%
    padding(padding = 2, part = "all")

  # fill each ROI cell with APA-italic rich text: beta, t, p, d are italic and
  # the whole cell is bold when its one-tailed... (here two-tailed) p < .05
  mk_par <- function(pre, tt, pp, dd, bold) {
    it <- fp_text_default(italic = TRUE, bold = bold, font.size = 8, font.family = "Garamond")
    pl <- fp_text_default(italic = FALSE, bold = bold, font.size = 8, font.family = "Garamond")
    as_paragraph(as_chunk("β", props = it), as_chunk(pre, props = pl),
                 as_chunk("t",      props = it), as_chunk(tt,  props = pl),
                 as_chunk("p",      props = it), as_chunk(pp,  props = pl),
                 as_chunk("d",      props = it), as_chunk(dd,  props = pl))
  }
  for (roi in region_order) {
    pv     <- p_tbl[[roi]]
    sig    <- which(!is.na(pv) & pv <  0.05)
    nonsig <- which(!is.na(pv) & pv >= 0.05)
    empty  <- which(is.na(pv))
    if (length(sig))
      ft <- compose(ft, i = sig, j = roi,
                    value = mk_par(w_pre[[roi]][sig], w_tt[[roi]][sig],
                                   w_pp[[roi]][sig], w_dd[[roi]][sig], TRUE))
    if (length(nonsig))
      ft <- compose(ft, i = nonsig, j = roi,
                    value = mk_par(w_pre[[roi]][nonsig], w_tt[[roi]][nonsig],
                                   w_pp[[roi]][nonsig], w_dd[[roi]][nonsig], FALSE))
    if (length(empty))
      ft <- compose(ft, i = empty, j = roi, value = as_paragraph(as_chunk("")))
  }
  ft <- fontsize(ft, size = 8, part = "all")
  ft <- font(ft, fontname = "Garamond", part = "all")

  # zebra shading: alternate light blue / white by experiment block
  for (k in seq_along(experiment_order)) {
    rows_k <- which(disp$experiment == experiment_order[k])
    if (length(rows_k) && (k %% 2 == 1))
      ft <- bg(ft, i = rows_k, bg = "#C6D9F1", part = "body")
  }

  # fixed column widths (twips / 1440 = inches), matching the hand-tuned layout
  ft <- width(ft, j = "experiment", width = 950 / 1440)
  ft <- width(ft, j = "contrast",   width = 1750 / 1440)
  for (roi in region_order) ft <- width(ft, j = roi, width = 2568 / 1440)
  ft <- set_table_properties(ft, layout = "fixed")

  # A4 page with 0.5" margins so the table fits
  sect <- prop_section(
    page_size    = page_size(width = 12240 / 1440, height = 15840 / 1440, orient = "portrait"),  # US Letter
    page_margins = page_mar(top = 0.5, bottom = 0.5, left = 0.5, right = 0.5)
  )
  doc <- read_docx() %>%
    body_add_flextable(ft) %>%
    body_set_default_section(sect)

  print(doc, target = file.path(savePath, paste0(docName, ".docx")))
}

# ------------------------------------------------------------------------------
# ---------------------------- prepare data ------------------------------------
# ------------------------------------------------------------------------------


workDir <- ''  # <-- SET THIS to the path of the statisticalAnalyses folder (must end in '/'), e.g. '~/Downloads/statisticalAnalyses/'
dataDir <- paste0(workDir,'data/')
imgDir <- paste0(workDir,'plots/')
resultsDir <- paste0(workDir,'results/')

# read in the data for all of the experiments (surface + MNI, with subcortical
# dyLoc grafted from the old files); see code/load_fROI_data.R
source(paste0(workDir,'code/load_fROI_data.R'))
allfROIdata <- load_fROI_data(dataDir)
allfROIdata$roiNames <- rename_surface_rois(allfROIdata$roi)
allfROIdata$designation <- "none"

# build the wide-format dyLoc table used by the face-selectivity models.
# indBeta = the (independent) dyLoc betas; fac/bod/obj/scn/scr are one-hot
# indicators of which condition each beta comes from.
fROIdata <- allfROIdata %>%
  filter(experiment == "dyLoc") %>%
  transmute(
    subject, roi, roiNames, condition,
    indBeta = betas,
    fac = as.integer(condition == "Faces"),
    bod = as.integer(condition == "Bodies"),
    obj = as.integer(condition == "Objects"),
    scn = as.integer(condition == "Scenes"),
    scr = as.integer(condition == "Scrambled")
  )
fROIdata$designation <- "none"

# ------------------------------------------------------------------------------
# ------------------- print the outputs to a file ------------------------------
# ------------------------------------------------------------------------------


# print the outputs to a text file
sink(file = paste0(resultsDir, 'faceSelect_statistics_20260728.txt'))

# ------------------------------------------------------------------------------
# --------------- stats for face selective / preferring ------------------------
# ------------------------------------------------------------------------------

print('=======================================================================')
print('...................test fROIs for face preferences.....................')
print('=======================================================================')

# test the response in all ROIs
roiList=unique(fROIdata$roiNames)
print(c('number of face-responsive regions:',length(roiList)))
for (i in 1:length(roiList)) { 
  
  # get all of the data for this ROI
  roiData <-  filter(fROIdata, roiNames==roiList[i] )
  
  # run the models
  facGLM <- lmer(indBeta ~ bod + obj + scn + scr + (1|subject), data = roiData)

  # results for face selectivity model
  facCoefs <- data.frame(coef(summary(facGLM)))
  
  # compute 1-tailed statistics
  fac_p <- one_tail_p_value(facCoefs[1,1], facCoefs[1,5], face=TRUE)
  bod_p <- one_tail_p_value(facCoefs[2,1], facCoefs[2,5], face=FALSE)
  obj_p <- one_tail_p_value(facCoefs[3,1], facCoefs[3,5], face=FALSE)
  scn_p <- one_tail_p_value(facCoefs[4,1], facCoefs[4,5], face=FALSE)
  scr_p <- one_tail_p_value(facCoefs[5,1], facCoefs[5,5], face=FALSE)
  
  if ( (fac_p<0.05) & (bod_p<0.05) & (obj_p<0.05) & (scn_p<0.05) & (scr_p<0.05) ) {
    print(paste0(roiList[i], ' IS FACE SELECTIVE'))
    fROIdata$designation[fROIdata$roiNames==roiList[i]] <- "Selective"
    allfROIdata$designation[allfROIdata$roiNames==roiList[i]] <- "Selective"
  } else if ( (obj_p<0.05) & (scn_p<0.05) & (scr_p<0.05) ) {
    print(paste0(roiList[i], 'People Selective (Face & Body)'))
    fROIdata$designation[fROIdata$roiNames==roiList[i]] <- "Preference"
    allfROIdata$designation[allfROIdata$roiNames==roiList[i]] <- "Preference"
  } else if ( obj_p<0.05)  {
    print(paste0(roiList[i], ' Candidate Face Region'))
    fROIdata$designation[fROIdata$roiNames==roiList[i]] <- "Preference"
    allfROIdata$designation[allfROIdata$roiNames==roiList[i]] <- "Preference"
  } else {
    print(paste0(roiList[i], ' does NOT pass cross validation'))
    fROIdata$designation[fROIdata$roiNames==roiList[i]] <- "NotReliable"
    allfROIdata$designation[allfROIdata$roiNames==roiList[i]] <- "NotReliable"
  }
}
print('.......................................................................')

# ------------------------------------------------------------------------------
# ------------------------ compute fROI statistcs ------------------------------
# ------------------------------------------------------------------------------

print('=======================================================================')
print('................test fROIs for face selectivity........................')
print('=======================================================================')

# collect per-region estimates to regenerate Table S3 (face selectivity)
selRows <- list()

for (i in 1:length(roiList)) {
  print(roiList[i])
  
  # get all of the data for this ROI
  roiData <-  filter(fROIdata, roiNames==roiList[i] )
  
  # run the models
  facGLM <- lmer(indBeta ~ bod + obj + scn + scr + (1|subject), data = roiData)
  
  # results for face selectivity model
  print(paste0(roiList[i],' test for face selectivity'))
  facCoefs <- data.frame(coef(summary(facGLM)))

  # print the results for each fROI
  print(paste0('     fac > fix beta=',round(facCoefs[1,1],digits=2),' se=', round(facCoefs[1,2],digits=2), ' p=', 
               round_to_first_nonzero(one_tail_p_value(facCoefs[1,1] , facCoefs[1,5], face=TRUE),n_digits=2)
               ))
  print(paste0('     fac > bod beta=',round(facCoefs[2,1],digits=2),' se=', round(facCoefs[2,2],digits=2), ' p=', 
               round_to_first_nonzero(one_tail_p_value(facCoefs[2,1] , facCoefs[2,5], face=FALSE),n_digits=2)
               ))
  print(paste0('     fac > obj beta=',round(facCoefs[3,1],digits=2),' se=', round(facCoefs[3,2],digits=2), ' p=', 
               round_to_first_nonzero(one_tail_p_value(facCoefs[3,1] , facCoefs[3,5], face=FALSE),n_digits=2)
               ))
  print(paste0('     fac > scn beta=',round(facCoefs[4,1],digits=2),' se=', round(facCoefs[4,2],digits=2), ' p=', 
               round_to_first_nonzero(one_tail_p_value(facCoefs[4,1] , facCoefs[4,5], face=FALSE),n_digits=2)
               ))
  print(paste0('     fac > scr beta=',round(facCoefs[5,1],digits=2),' se=', round(facCoefs[5,2],digits=2), ' p=',
               round_to_first_nonzero(one_tail_p_value(facCoefs[5,1] , facCoefs[5,5], face=FALSE),n_digits=2)
               ))

  # ---- capture values + designation for the Table S3 (face selectivity) ----
  fac_p <- one_tail_p_value(facCoefs[1,1], facCoefs[1,5], face=TRUE)
  bod_p <- one_tail_p_value(facCoefs[2,1], facCoefs[2,5], face=FALSE)
  obj_p <- one_tail_p_value(facCoefs[3,1], facCoefs[3,5], face=FALSE)
  scn_p <- one_tail_p_value(facCoefs[4,1], facCoefs[4,5], face=FALSE)
  scr_p <- one_tail_p_value(facCoefs[5,1], facCoefs[5,5], face=FALSE)
  if (fac_p<0.05 & bod_p<0.05 & obj_p<0.05 & scn_p<0.05 & scr_p<0.05) {
    catDetail <- "Selective"
  } else if (obj_p<0.05 & scn_p<0.05 & scr_p<0.05) {
    catDetail <- "FaceBody"
  } else if (obj_p<0.05) {
    catDetail <- "Preference"
  } else {
    catDetail <- "NotReliable"
  }
  selRows[[length(selRows)+1]] <- data.frame(
    roiNames = roiList[i], category = catDetail,
    fac_b=facCoefs[1,1], fac_se=facCoefs[1,2], fac_p=fac_p,
    bod_b=facCoefs[2,1], bod_se=facCoefs[2,2], bod_p=bod_p,
    obj_b=facCoefs[3,1], obj_se=facCoefs[3,2], obj_p=obj_p,
    scn_b=facCoefs[4,1], scn_se=facCoefs[4,2], scn_p=scn_p,
    scr_b=facCoefs[5,1], scr_se=facCoefs[5,2], scr_p=scr_p,
    stringsAsFactors = FALSE)
}
print('.......................................................................')
print(' ')
print('=======================================================================')
print('......................how many face selective regions..................')
print('=======================================================================')
print(' ')
# how many face-selective regions are there?
faceSelectDF <-  filter(allfROIdata, designation=="Selective")
print(paste0('number of face-selective regions:  ',length(unique(faceSelectDF$roiNames))))
print(' ')
print('.......................................................................')
print(' ')

# ------------------------------------------------------------------------------
# -------------------- ANOVAs for each experiment ------------------------------
# ------------------------------------------------------------------------------
print('=======================================================================')
print('......test for region x condition interaction for each experiment......')
print('=======================================================================')
print(' ')

# need to norm the data for each experiment within each fROI
# see references on fMRI mega analyses
exps <- unique(allfROIdata$experiment)
rois <- unique(allfROIdata$roi)
for (i in 1:length(exps)) {
  eSet <- filter(allfROIdata, experiment==exps[i] )
  for (j in 1:length(rois)) {
    dSet <- filter(eSet, roi==rois[j] )
    dSet$normBeta <- scale(dSet$betas)
    if (i == 1 & j == 1) {
      fROIdataNormed <- dSet
    } else {
      fROIdataNormed <- bind_rows(fROIdataNormed, dSet)
    }
  }
}

faceSelectDF <-  filter(fROIdataNormed, designation=="Selective")

print('full omnibus ANOVA')
omniLME <- lmer(normBeta ~ roiNames * condition + (1|subject), data = faceSelectDF)
print(anova(omniLME))

# posthoc ANOVAs
ffa_sts_df <- filter(fROIdataNormed, roiNames=="R-FFA" | roiNames=="L-FFA" | roiNames=="L-PSTS" | roiNames=="R-PSTS",
                      experiment=="gesture")
ffa_sts_lme <- lmer(normBeta ~ roiNames * condition + (1|subject), data = ffa_sts_df)
print('FFA X STS ANOVA')
print(anova(ffa_sts_lme))

clstDFmega <- fROIdataNormed %>%
  filter(experiment=="mega",
         roiNames %in% c("R-IPL", "R-VLAT", "R-PC",
                         "L-VLAT", "R-SFG", "R-MPFC")) %>%
  mutate(
    roiGroup = case_when(
      roiNames %in% c("R-IPL", "R-VLAT", "L-VLAT") ~ "Group1",
      roiNames %in% c("R-PC", "R-SFG", "R-MPFC") ~ "Group2"
    )
  )
clstLMEmega <- lmer(normBeta ~ roiGroup * condition + (1|subject), data = clstDFmega)
print('ANOVA for DN-B clusters')
print(anova(clstLMEmega))

clstDFlang <- fROIdataNormed %>%
  filter(experiment=="lang2cond",
         roiNames %in% c("R-FFA", "R-OFA", "L-FFA", "R-PC",
                         "L-PSTS", "L-ASTS", "L-MSTS", "R-MSTS")) %>%
  mutate(
    roiGroup = case_when(
      roiNames %in% c("R-FFA", "R-OFA", "L-FFA", "R-PC") ~ "Group1",
      roiNames %in% c("L-PSTS", "L-ASTS", "L-MSTS", "R-MSTS") ~ "Group2"
    )
  )
langLMErois <- lmer(normBeta ~ roiNames * condition + (1|subject), data = clstDFmega)
print('ANOVA for LANG fROIs')
print(anova(langLMErois))
langLMEgroups <- lmer(normBeta ~ roiGroup * condition + (1|subject), data = clstDFmega)
print('ANOVA for LANG groups')
print(anova(langLMEgroups))

# ------------------------------------------------------------------------------
# --- Table S4: experiment-level ANOVAs (fROI x Condition, face-selective) -----
# ------------------------------------------------------------------------------
# for each experiment, ANOVA of normBeta ~ fROI * condition on the face-selective
# fROIs (lmer + anova; Satterthwaite df)
s4_exps  <- c("dyLoc", "tom", "lang2cond", "tva", "plw", "shape", "mega", "bio", "gesture", "eib1")
s4_names <- c("Dynamic Face Localizer", "ToM Loc", "Lang Loc", "Voice Loc", "PLWs",
              "Animate Agents", "Story Listening", "PLDs", "Gestures", "Social Inference")
selectList <- list(); n <- 1
for (iExp in seq_along(s4_exps)) {
  expSelectDF  <- filter(faceSelectDF, experiment == s4_exps[iExp])
  expSelectLME <- suppressWarnings(lmer(normBeta ~ roiNames * condition + (1|subject), data = expSelectDF))
  s <- anova(expSelectLME)
  print(paste0(s4_names[iExp], 'ANOVA'))
  print(s)
  for (k in 1:3) {
    selectList[[n]] <- data.frame(
      exp   = s4_names[iExp],
      param = c("fROI", "Condition", "fROI × Condition")[k],
      fVal  = s$`F value`[k], numDF = s$NumDF[k], denDF = s$DenDF[k], pVal = s$`Pr(>F)`[k]
    )
    n <- n + 1
  }
}
dfSelectAnovas <- do.call(rbind, selectList)
create_word_table_4_anovas(dfSelectAnovas, s4_names, "TableS04_experimentANOVAs")

print('.......................................................................')
print(' ')

# ------------------------------------------------------------------------------
# ------------------------- pairwise comparisons  ------------------------------
# ------------------------------------------------------------------------------

print('=======================================================================')
print('.................test for contrast differences....................')
print('=======================================================================')
print(' ')

# create a list to store the outputs for each fROI / experiment combination
resultsList <- list()
# make sure we go through each experiment once
exps <- unique(allfROIdata$experiment)
# make sure we go through each fROI once
roiList <- unique(fROIdataNormed$roiNames)
# now go ahead and go through the loops
for (iROI in seq_along(roiList)) {
  # create a data frame for this fROI
  fROIname <- roiList[[iROI]]
  roiDF <- filter(fROIdataNormed, roiNames == fROIname)
  for (iExp in seq_along(exps)) {
    # get the pairwise contrasts for this fROI and combine it all together
    exp <- exps[[iExp]]
    tmpResDF <- results_list(exp, roiDF, fROIname)
    resultsList[[length(resultsList) + 1]] <- tmpResDF
  }
}
# put it all into a lovely data frame
dfResults <- do.call(rbind, resultsList)

# relabel experiments and contrasts to their manuscript display names
exp_labels <- c("DyLoc" = "Dynamic Face Localizer", "Vocal" = "Voice Loc",
                "Shape" = "Animate Agents", "Auditory" = "Story Listening",
                "Gesture" = "Gestures", "Emo Inf" = "Social Inference")
con_labels <- c("FvO"="F>O","FvB"="F>B","FvS"="F>S","FvSc"="F>Scr","BvO"="B>O","OvSc"="O>Scr",
                "FBvFP"="FB>FP","INTvALT"="Words>Nons","VOCvNON"="Voc>Non","INTvNINT"="Int>Nint",
                "HELPvHIND"="Help>Hind","AGTvPHS"="Agt>Inan","2v1"="2Agts>1Agt",
                "LANGvNON"="Stories>Ctrl","ToMvBOD"="ToM>Body","VvM"="Speech>Music","PPLvOBJ"="People>Object",
                "BIOvOBJ"="Bio>Obj","BIOvBSCR"="Bio>BioScr","OBJvOSCR"="Obj>ObjScr",
                "OCCvNOT"="Video>NoVid","GESTvGRM"="Gest>Groom","SPvSIL"="Sp>Sil",
                "MvF"="Male>Female","PEXPvNEXP"="PosExp>NegExp","PPLvCRT"="People>Cartoon",
                "GRPvAGT"="Group>Agent","POSvNEG"="Pos>Neg","SUCvFAIL"="Succ>Fail","INCvEX"="Incl>Excl")
dfResults$experiment <- ifelse(dfResults$experiment %in% names(exp_labels),
                               exp_labels[dfResults$experiment], dfResults$experiment)
dfResults$contrast   <- ifelse(dfResults$contrast %in% names(con_labels),
                               con_labels[dfResults$contrast], dfResults$contrast)

# orders (display names; contrasts reordered within Story Listening / Gestures /
# Social Inference per the manuscript)
experiment_order <- c("Dynamic Face Localizer", "ToM Loc", "Lang Loc", "Voice Loc", "PLWs",
                      "Animate Agents", "Story Listening", "PLDs", "Gestures", "Social Inference")

contrast_order <- c("F>O", "F>B", "F>S", "F>Scr", "B>O", "O>Scr",
                    "FB>FP", "Words>Nons", "Voc>Non", "Int>Nint",
                    "Help>Hind", "Agt>Inan", "2Agts>1Agt",
                    "People>Object", "ToM>Body", "Stories>Ctrl", "Speech>Music",
                    "Bio>Obj", "Bio>BioScr", "Obj>ObjScr",
                    "Gest>Groom", "Sp>Sil", "Video>NoVid",
                    "People>Cartoon", "Group>Agent", "Male>Female", "Pos>Neg",
                    "PosExp>NegExp", "Incl>Excl", "Succ>Fail")

# Run it
savePath <- paste0(resultsDir, 'contrasts/')

vtc1 <- c("R-OFA", "L-FFA", "R-FFA")
vtc1doc <- "TableS05"
wordTable(dfResults, vtc1, experiment_order, contrast_order, vtc1doc, savePath)

vtc2 <- c("L-AFG", "R-AFG", "R-EC")
vtc2doc <- "TableS06"
wordTable(dfResults, vtc2, experiment_order, contrast_order, vtc2doc, savePath)

ltc1 <- c("R-MTiP", "R-PSTS", "L-PSTS" )
ltc1doc <- "TableS07"
wordTable(dfResults, ltc1, experiment_order, contrast_order, ltc1doc, savePath)

ltc2 <- c("R-MSTS", "L-MSTS", "R-ASTS")
ltc2doc <- "TableS08"
wordTable(dfResults, ltc2, experiment_order, contrast_order, ltc2doc, savePath)

ltc3 <- c("L-ASTS", "R-VLAT", "L-VLAT")
ltc3doc <- "TableS09"
wordTable(dfResults, ltc3, experiment_order, contrast_order, ltc3doc, savePath)

ltc4 <- c("R-STG", "R-PC", "R-IPL")
ltc4doc <- "TableS10"
wordTable(dfResults, ltc4, experiment_order, contrast_order, ltc4doc, savePath)

par2 <- c("R-SMG", "R-PCu", "L-PO")
par2doc <- "TableS11"
wordTable(dfResults, par2, experiment_order, contrast_order, par2doc, savePath)

lpfc1 <- c("R-PO", "R-MFG", "R-LOFC")
lpfc1doc <- "TableS12"
wordTable(dfResults, lpfc1, experiment_order, contrast_order, lpfc1doc, savePath)

lpfc2 <- c("R-VAI", "L-LOFC", "L-PTr")
lpfc2doc <- "TableS13"
wordTable(dfResults, lpfc2, experiment_order, contrast_order, lpfc2doc, savePath)

lpfc3 <- c("R-CACC", "R-ACC", "L-ACC")
lpfc3doc <- "TableS14"
wordTable(dfResults, lpfc3, experiment_order, contrast_order, lpfc3doc, savePath)

mpfc1 <- c("R-SFG", "R-MPFC", "L-MPFC")
mpfc1doc <- "TableS15"
wordTable(dfResults, mpfc1, experiment_order, contrast_order, mpfc1doc, savePath)

mpfc2 <- c("R-PSFG", "L-Amyg", "R-Amyg")
mpfc2doc <- "TableS16"
wordTable(dfResults, mpfc2, experiment_order, contrast_order, mpfc2doc, savePath)

subctx1 <- c("L-GP", "R-GP", "L-VDC")
subctx1doc <-"TableS17"
wordTable(dfResults, subctx1, experiment_order, contrast_order, subctx1doc, savePath)

subctx2 <- c("R-VDC", "dmThal")
subctx2doc <-"TableS18"
wordTable(dfResults, subctx2, experiment_order, contrast_order, subctx2doc, savePath)

tbl21 <- c("R-CS", "R-CMFG", "L-RLOFC")
tbl21doc <- "TableS19"
wordTable(dfResults, tbl21, experiment_order, contrast_order, tbl21doc, savePath)

tbl22 <- c("R-RACC", "L-CACC", "R-OFC")
tbl22doc <- "TableS20"
wordTable(dfResults, tbl22, experiment_order, contrast_order, tbl22doc, savePath)

tbl23 <- c("L-OFC", "L-SFG", "L-PCC")
tbl23doc <- "TableS21"
wordTable(dfResults, tbl23, experiment_order, contrast_order, tbl23doc, savePath)

tbl24 <- c("R-PCC", "R-ICC", "R-PoCG")
tbl24doc <- "TableS22"
wordTable(dfResults, tbl24, experiment_order, contrast_order, tbl24doc, savePath)

tbl25 <- c("L-PoCG", "R-LiG", "L-LiG")
tbl25doc <- "TableS23"
wordTable(dfResults, tbl25, experiment_order, contrast_order, tbl25doc, savePath)

tbl26 <- c("R-CuLO", "L-CuLO",  "R-Caud")
tbl26doc <- "TableS24"
wordTable(dfResults, tbl26, experiment_order, contrast_order, tbl26doc, savePath)

tbl27 <- c("L-VS", "R-VS", "L-Put")
tbl27doc <- "TableS25"
wordTable(dfResults, tbl27, experiment_order, contrast_order, tbl27doc, savePath)

tbl28 <- c("R-Put", "L-Cerb", "R-Cerb2")
tbl28doc <- "TableS26"
wordTable(dfResults, tbl28, experiment_order, contrast_order, tbl28doc, savePath)

tbl29 <- c("R-pHipp", "L-Caud", "R-PreCG")
tbl29doc <- "TableS27"
wordTable(dfResults, tbl29, experiment_order, contrast_order, tbl29doc, savePath)

tbl30 <- c("R-PL",  "L-pHipp", "SC")
tbl30doc <- "TableS28"
wordTable(dfResults, tbl30, experiment_order, contrast_order, tbl30doc, savePath)

tbl31 <- c("R-Cerb1", "R-Cerb3")
tbl31doc <- "TableS29"
wordTable(dfResults, tbl31, experiment_order, contrast_order, tbl31doc, savePath)

# ------------------------------------------------------------------------------
# --------- Table S3: face-selectivity estimates for each fROI -----------------
# ------------------------------------------------------------------------------
# Regenerates the (previously hand-made) Table S3. An empty "Anatomy" column is
# left for the brain snapshots to be pasted in. fROI-name styling:
#   bold black = face-selective ; bold gray = face & body preference ;
#   plain black = face preference / not reliable.
# A numeric cell is bold when that condition's one-tailed p < 0.05.
# Condition columns follow the manuscript order: Faces, Objects, Bodies, Scenes, Scram.

selTable <- do.call(rbind, selRows)

# map display name -> parcel ID (LH-0xx / RH-0xx); subcortical -> "subcortex"
lh_names <- c("L-PCC","L-CACC","L-PO","L-PoCG","L-LiG","L-CuLO","L-PTr","L-RLOFC",
              "L-LOFC","L-SFG","L-OFC","L-ACC","L-MPFC","L-VLAT","L-ASTS","L-MSTS",
              "L-PSTS","L-AFG","L-FFA")
rh_names <- c("R-PO","R-MFG","R-CACC","R-PC","R-PSFG","R-LiG","R-CuLO","R-ACC",
              "R-PL","R-RACC","R-IPL","R-VAI","R-PCu","R-PCC","R-CMFG","R-ICC",
              "R-OFC","R-EC","R-CS","R-PreCG","R-PoCG","R-SFG","R-MPFC","R-VLAT",
              "R-LOFC","R-SMG","R-STG","R-MTiP","R-ASTS","R-MSTS","R-PSTS","R-OFA",
              "R-AFG","R-FFA")
nameToID <- c(setNames(sprintf("LH-%03d", seq_along(lh_names)), lh_names),
              setNames(sprintf("RH-%03d", seq_along(rh_names)), rh_names))
get_id <- function(nm) ifelse(nm %in% names(nameToID), nameToID[nm], "subcortex")

# row order = same region grouping used for the contrast tables (TableS05-S29)
region_order_full <- c(vtc1, vtc2, ltc1, ltc2, ltc3, ltc4, par2, lpfc1, lpfc2,
                       lpfc3, mpfc1, mpfc2, subctx1, subctx2, tbl21, tbl22, tbl23,
                       tbl24, tbl25, tbl26, tbl27, tbl28, tbl29, tbl30, tbl31)
selTable <- selTable[match(region_order_full, selTable$roiNames), ]
selTable <- selTable[!is.na(selTable$roiNames), ]

fmt_cell <- function(b, se) sprintf("%.2f\n(%.2f)", b, se)
disp <- data.frame(
  ID      = vapply(selTable$roiNames, get_id, character(1)),
  fROI    = selTable$roiNames,
  Anatomy = "",
  Faces   = fmt_cell(selTable$fac_b, selTable$fac_se),
  Objects = fmt_cell(selTable$obj_b, selTable$obj_se),
  Bodies  = fmt_cell(selTable$bod_b, selTable$bod_se),
  Scenes  = fmt_cell(selTable$scn_b, selTable$scn_se),
  Scram   = fmt_cell(selTable$scr_b, selTable$scr_se),
  stringsAsFactors = FALSE, check.names = FALSE
)

ft3 <- flextable(disp) %>%
  set_header_labels(ID = "ID", fROI = "fROI", Anatomy = "Anatomy",
                    Faces = "Faces**", Objects = "Objects*", Bodies = "Bodies*",
                    Scenes = "Scenes*", Scram = "Scram*") %>%
  align(j = c("Faces","Objects","Bodies","Scenes","Scram"), align = "center", part = "all") %>%
  align(j = c("ID","fROI","Anatomy"), align = "left", part = "all") %>%
  valign(valign = "center", part = "all") %>%
  theme_booktabs() %>%
  fontsize(size = 9, part = "all") %>%
  font(fontname = "Garamond", part = "all") %>%
  autofit()
ft3 <- width(ft3, j = "Anatomy", width = 1.0)   # room to paste brain snapshots

# fROI-name emphasis by designation
sel_i <- which(selTable$category == "Selective")
fb_i  <- which(selTable$category == "FaceBody")
if (length(sel_i)) ft3 <- bold(ft3, i = sel_i, j = "fROI", bold = TRUE, part = "body")
if (length(fb_i)) {
  ft3 <- bold(ft3,  i = fb_i, j = "fROI", bold = TRUE, part = "body")
  ft3 <- color(ft3, i = fb_i, j = "fROI", color = "gray50", part = "body")
}

# bold each numeric cell whose one-tailed p < 0.05
pcols <- c(Faces = "fac_p", Objects = "obj_p", Bodies = "bod_p",
           Scenes = "scn_p", Scram = "scr_p")
for (cn in names(pcols)) {
  sig <- which(selTable[[pcols[[cn]]]] < 0.05)
  if (length(sig)) ft3 <- bold(ft3, i = sig, j = cn, bold = TRUE, part = "body")
}

doc3 <- read_docx() %>% body_add_flextable(ft3) %>%
  body_set_default_section(prop_section(
    page_size    = page_size(width = 12240/1440, height = 15840/1440, orient = "portrait"),  # US Letter
    page_margins = page_mar(top = 1, bottom = 1, left = 1, right = 1)))
print(doc3, target = paste0(resultsDir, "TableS03_faceSelectivity.docx"))

# finish printing results to text file
sink(file = NULL)

# ------------------------------------------------------------------------------
# ----------------------- compute fROI similarity ------------------------------
# ------------------------------------------------------------------------------
print(' ')
print('=======================================================================')
print('.......................compute fROI similarity.........................')
print('=======================================================================')
print(' ')

# 1. normalized mean responses for each fROI
# 2. standard error of mean responses for each fROI
# 3. corr
# # # do this only for the subset of fROIs that have face selectivity or prefs

# get means and z-values for each condition in each fROI
roiMeans <- faceSelectDF %>%
  group_by(condition, roiNames) %>%
  summarize(meanBeta = mean(betas, na.rm = TRUE), .groups = 'drop') %>%
  group_by(roiNames) %>%
  mutate(zScore = as.numeric(scale(meanBeta))) %>%
  as.data.frame()

# using correlation distance because we care about the overall pattern of
# response across conditions, not the magnitude of response. We don't care
# as much about the magnitude of response because magnitude can change as a
# function of brain region depending on the vascularization of the brain region
# and we are looking for how similar the responses of the fROIs are across
# conditions, not how strong the responses are across fROIs

# Convert to a matrix using xtabs
faceMatrix <- xtabs(zScore ~ condition + roiNames, data = roiMeans)

# correlation distance
faceCorr <- 1-cor(faceMatrix)

# hierarchical clustering based on correlation distances
corHC <- hclust(as.dist(faceCorr), method = "ward.D2")
# Convert to dendrogram
dend <- as.dendrogram(corHC)

# rotate branches to the manuscript ROI order. This is a valid flip: the
# clustering, merge heights, and topology are unchanged -- only the drawing
# order of sibling branches. The order below is achievable by rotation alone.
roiOrder <- c("R-FFA","R-OFA","L-FFA","L-AFG","R-EC","R-CACC","R-PSFG","R-Amyg","L-GP","R-GP","L-PO","L-PSTS",
              "R-MTiP","R-SMG","R-MFG","R-STG","R-AFG","R-LOFC","R-PC","R-MPFC","R-SFG",
              "R-PO","R-PSTS","R-MSTS","L-MSTS","L-ASTS","R-ASTS","R-VAI","L-VLAT","R-VLAT","R-IPL")
dend <- dendextend::rotate(dend, roiOrder)

# Convert dendrogram to a dendro_data object for manipulation
dend_data <- dendro_data(dend)

# Extract segment and label data (horizontal layout: swap x/y so the tree grows
# leftward from the root and leaf labels sit on the right; R-FFA at top)
segs <- dend_data$segments
labs <- dend_data$labels
hmax <- max(segs$y)

hcPlot <- ggplot() +
  geom_segment(data = segs,
               aes(x = y, y = x, xend = yend, yend = xend),
               colour = "black", linewidth = 0.5) +
  geom_text(data = labs,
            aes(x = -0.008 * hmax, y = x, label = label),
            hjust = 0, size = 4.6, family = "Helvetica", colour = "black") +
  scale_x_reverse(expand = expansion(mult = c(0.02, 0.14))) +   # room for labels on the right
  scale_y_reverse(expand = expansion(add = 0.6)) +              # R-FFA at top
  coord_cartesian(clip = "off") +
  theme_void() +
  theme(plot.margin = margin(6, 6, 6, 6))

imgFN <- paste0(imgDir, "hierarchicalClustering.png")
ggsave(imgFN, hcPlot, width = 8.5, height = 11, unit = "in", dpi = 300, device = "png", bg = "transparent")

print('=======================================================================')
print('.............................. FINISHED ...............................')
print('=======================================================================')

# flextable's autofit() opens a graphics device in batch mode; drop the stray file
if (file.exists("Rplots.pdf")) invisible(file.remove("Rplots.pdf"))



