if(!require("ggplot2")) {install.packages("ggplot2"); require ("ggplot2")}
if(!require("tidyverse")) {install.packages("tidyverse"); require ("tidyverse")}
if(!require("Rmisc")) {install.packages("Rmisc"); require ("Rmisc")}
if(!require("dplyr")) {install.packages("dplyr"); require ("dplyr")}

# based on barPlots_20260502.R, updated for the 2026-07 re-run:
#   - reads the new surface + MNI files (with subcortical dyLoc grafted) via
#     code/load_fROI_data.R
#   - cortical parcels arrive already named ("L-FFA.label"); drop the suffix
#   - dyLoc conditions are capitalized (Faces/Bodies/Objects/Scenes/Scrambled)

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
  roiNames[roiNames == "L-ventralDC"] <- "L-vDC"
  roiNames[roiNames == "R-ventralDC"] <- "R-vDC"
  roiNames[roiNames == "L-putamen"] <- "L-Put"
  roiNames[roiNames == "R-putamen"] <- "R-Put"
  roiNames[roiNames == "sc"] <- "SC"
  # cortical surface parcels are already named; drop the ".label" suffix
  roiNames <- sub("\\.label$", "", roiNames)
  return(roiNames)
}

hex_colors <- c("#5C2997", "#EFBC40","#8A356C", "#3D8D26", "#7B7B7B", "#FFFFFF",
                "#009051", "#A6C8B0",  "#FFFFFF",
                "#942193", "#C395C6",  "#FFFFFF",
                "#0068DA", "#95B2E9",  "#FFFFFF",
                "#FF9300", "#F8CD9F",  "#FFFFFF",
                "#F0BD41", "#F4D17B", "#FAE8BF", "#FEF9EC",  "#FFFFFF",
                "#009193", "#7FB2B3", "#A6C9C9", "#CADFDF", "#DCE9EA", "#EDF4F5",  "#FFFFFF",
                "#882111", "#AD6D63", "#C69A93", "#DDC3BF", "#E8D8D5", "#F4EBEA",  "#FFFFFF",
                "#8A356C", "#AE799B", "#C6A1B8", "#D8BFCE", "#E9DBE4",  "#FFFFFF",
                "#5C2997", "#7F5BAC", "#997CBC", "#B29CCC", "#C1B1D6", "#D1C5E0", "#E1D8EB", "#EFECF5")

condition <- c('Faces','Objects','Bodies','Scenes','Scrambled', 'NULL',
               'FB','FP', 'NULL',
               'SENT','NONS', 'NULL',
               'Vocal','nonvocal', 'NULL',
               'plwInt','plwNoInt', 'NULL',
               'help','hinder','noInteraction','physics', 'NULL',
               'ToM','Bio','PMo','PNM','Jab','Mus', 'NULL',
               'BioMot','BioScram','Coh','Sfm','SfmScram','Static', 'NULL',
               'A','GA','GNA','NGA','NGNA', 'NULL',
               'mh','mu','fh','fu','sh','su','nh','nu')

workDir <- ''  # <-- SET THIS to the path of the statisticalAnalyses folder (NO trailing slash), e.g. '~/Downloads/statisticalAnalyses'
dataDir <- paste0(workDir,'/data/')
imgDir <- paste0(workDir,'/plots/roiPlots/')
dir.create(imgDir, recursive = TRUE, showWarnings = FALSE)

# read in the volume and surface fROIs (surface + MNI, with subcortical dyLoc
# grafted from the old files); see code/load_fROI_data.R
source(paste0(workDir,'/code/load_fROI_data.R'))
fullDF <- load_fROI_data(dataDir)
fullDF$roiNames <- rename_surface_rois(fullDF$roi)


# get the parameters for the plots
w <- 8
h <- 1.5
textSize <- 10
acc <- 0.01
lw <- 0.1

# loop through each fROI and plot it
rois <- unique(fullDF$roiNames)
for (i in 1:length(rois)) {

  # get all of the data for this ROI
  roiData <-  filter(fullDF, roiNames==rois[i])

  # compute the within-subject standard error
  SE_within <- summarySEwithin(roiData, measurevar="betas", withinvars="condition", idvar="subject", na.rm=TRUE)

  # make a null entry for spaces between experiments
  Null.Entry <- data.frame("NULL", 0, 0, 0, 0, 0)
  names(Null.Entry) <- c("condition", "N", "betas", "sd", "se", "ci")
  seDF <- rbind(SE_within,Null.Entry)

  # plot all of the experiments
  roiPlat <- ggplot2::ggplot(seDF, aes(x = condition, y = betas, fill = condition)) +
    geom_errorbar(aes(ymin=betas-(betas<0)*se, ymax=betas+(betas>0)*se),
                  width = 0.1, linewidth=lw, data = seDF) +
    geom_bar(color = "black", linewidth=lw, stat="identity", position="stack") +
    labs(y = "Mean Beta", x=element_blank()) + theme_bw() + theme(legend.position = "none")  +
    theme(panel.border = element_blank(), panel.grid.major = element_blank(),  axis.line.x = element_blank(),
          panel.grid.minor=element_blank(), axis.line.y = element_line(colour = "black", linewidth=lw),
          plot.margin = margin(t=10, r=1, b=10, l=2)) +
    theme(text=element_text(size = textSize))  +
    geom_hline(yintercept = 0, colour = "black", linewidth=lw) +
    theme(axis.text.y=element_text(size = textSize, family = "Helvetica", colour = "black"),
          axis.text.x = element_blank(), axis.title.x = element_blank(),
          axis.title.y = element_text(size = textSize, family = "Helvetica", colour = "black")) +
    scale_y_continuous(labels = scales::label_number(accuracy = acc)) +
    scale_x_discrete(limits = condition) + theme(axis.ticks = element_blank()) +
    scale_fill_manual(limits=condition, values=hex_colors)
  roiPlat
  imgFN <- paste0(imgDir, roiData$roiNames[1], ".png")
  ggsave(imgFN, roiPlat, width=w, height=h, unit="in", dpi=300, device="png")

}



# need to norm the data for each experiment within each fROI
# see references on fMRI mega analyses
exps <- unique(fullDF$experiment)
rois <- unique(fullDF$roi)
for (i in 1:length(exps)) {
  eSet <- filter(fullDF, experiment==exps[i] )
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



# loop through each fROI and plot it
imgDir <- paste0(workDir,'/plots/roiPlots_normed/')
dir.create(imgDir, recursive = TRUE, showWarnings = FALSE)
rois <- unique(fROIdataNormed$roiNames)
for (i in 1:length(rois)) {

  # get all of the data for this ROI
  roiData <-  filter(fROIdataNormed, roiNames==rois[i])

  # compute the within-subject standard error
  SE_within <- summarySEwithin(roiData, measurevar="betas", withinvars="condition", idvar="subject", na.rm=TRUE)

  # make a null entry for spaces between experiments
  Null.Entry <- data.frame("NULL", 0, 0, 0, 0, 0)
  names(Null.Entry) <- c("condition", "N", "betas", "sd", "se", "ci")
  seDF <- rbind(SE_within,Null.Entry)

  # plot all of the experiments
  roiPlat <- ggplot2::ggplot(seDF, aes(x = condition, y = betas, fill = condition)) +
    geom_errorbar(aes(ymin=betas-(betas<0)*se, ymax=betas+(betas>0)*se),
                  width = 0.1, linewidth=lw, data = seDF) +
    geom_bar(color = "black", linewidth=lw, stat="identity", position="stack") +
    labs(y = "Mean Beta", x=element_blank()) + theme_bw() + theme(legend.position = "none")  +
    theme(panel.border = element_blank(), panel.grid.major = element_blank(),  axis.line.x = element_blank(),
          panel.grid.minor=element_blank(), axis.line.y = element_line(colour = "black", linewidth=lw),
          plot.margin = margin(t=10, r=1, b=10, l=2)) +
    theme(text=element_text(size = textSize))  +
    geom_hline(yintercept = 0, colour = "black", linewidth=lw) +
    theme(axis.text.y=element_text(size = textSize, family = "Helvetica", colour = "black"),
          axis.text.x = element_blank(), axis.title.x = element_blank(),
          axis.title.y = element_text(size = textSize, family = "Helvetica", colour = "black")) +
    scale_y_continuous(labels = scales::label_number(accuracy = acc)) +
    scale_x_discrete(limits = condition) + theme(axis.ticks = element_blank()) +
    scale_fill_manual(limits=condition, values=hex_colors)
  roiPlat
  imgFN <- paste0(imgDir, roiData$roiNames[1], ".png")
  ggsave(imgFN, roiPlat, width=w, height=h, unit="in", dpi=300, device="png")

}
