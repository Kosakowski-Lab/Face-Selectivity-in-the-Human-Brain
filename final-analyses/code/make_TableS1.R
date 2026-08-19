# =============================================================================
# make_TableS1.R  — participant counts per condition per dataset (Table S1)
# -----------------------------------------------------------------------------
# Counts ANALYZED subjects only (>=1 dyLoc run => valid face fROI). Rules:
#   * >=1 dyLoc run  -> counted in the other-experiment rows
#   * >=2 dyLoc runs -> counted in the dyLoc face-selectivity condition rows
#   * dyLoc conditions available per dataset:
#       cohen / EvLab / isik-5cond = all 5;  deen = Faces,Objects,Bodies;
#       isik-2cond & skerry = Faces,Objects only
# Datasets: DS1 Cohen2019, DS2 Deen2015, DS3 Isik2017, DS4 Jouravlev2019,
#           DS5 Skerry&Saxe2014, DS6 Lipkin2022 (EvLab split by gesture).
# Inputs (from the MATLAB count script): data/subj_dyloc_counts_*.csv and
#          data/subj_exp_counts_*.csv. Output: results/TableS01_participants.docx
# =============================================================================
if(!require("magrittr"))  {install.packages("magrittr");  require("magrittr")}
if(!require("officer"))   {install.packages("officer");   require("officer")}
if(!require("flextable")) {install.packages("flextable"); require("flextable")}

workDir    <- ''  # <-- SET THIS to the path of the statisticalAnalyses folder (must end in '/'), e.g. '~/Downloads/statisticalAnalyses/'
dataDir    <- paste0(workDir,'data/')
resultsDir <- paste0(workDir,'results/')

# most recent manifest files
dyfn <- sort(Sys.glob(paste0(dataDir,'subj_dyloc_counts_*.csv')), decreasing = TRUE)[1]
exfn <- sort(Sys.glob(paste0(dataDir,'subj_exp_counts_*.csv')),   decreasing = TRUE)[1]
dy <- read.csv(dyfn, stringsAsFactors = FALSE)   # dylocSubjs, dylocRuns, Group
ex <- read.csv(exfn, stringsAsFactors = FALSE)   # subjID, expName, Group
message("Table S1 from: ", basename(dyfn), " + ", basename(exfn))

DScols <- c('DS1','DS2','DS3','DS4','DS5','DS6')
gesture_subs <- unique(ex$subjID[ex$expName == 'gesture'])

DSof <- function(subj, grp) {
  if (grepl('deen',   grp)) return('DS2')
  if (grepl('isik',   grp)) return('DS3')
  if (grepl('skerry', grp)) return('DS5')
  if (grepl('cohen',  grp)) return('DS1')
  if (grp == 'EvLab') return(if (subj %in% gesture_subs) 'DS4' else 'DS6')
  NA
}
dy$DS <- mapply(DSof, dy$dylocSubjs, dy$Group)

conds_of <- function(grp) {
  if (grp == 'deen2015')                          return(c('Faces','Objects','Bodies'))
  if (grp %in% c('isik2017_2cond','skerry2014'))  return(c('Faces','Objects'))
  c('Faces','Objects','Bodies','Scenes','Scrambled')          # cohen*, EvLab, isik-5cond
}

# ---- count helpers (return named 6-vector over DScols) ----
zero <- function() setNames(integer(6), DScols)
dyloc_by_cond <- function(sub, cond) {
  out <- zero()
  for (i in seq_len(nrow(sub)))
    if (cond %in% conds_of(sub$Group[i])) out[sub$DS[i]] <- out[sub$DS[i]] + 1L
  out
}
DS_of_subj <- setNames(dy$DS, dy$dylocSubjs)
other_exp <- function(expname) {
  subs <- unique(ex$subjID[ex$expName == expname])
  subs <- subs[subs %in% dy$dylocSubjs]           # must have a face fROI (>=1 run)
  out <- zero(); ds <- DS_of_subj[subs]
  for (d in DScols) out[d] <- sum(ds == d, na.rm = TRUE)
  out
}

ge2 <- dy[dy$dylocRuns >= 2, ]
one <- dy[dy$dylocRuns == 1, ]
dcond <- c('Faces','Objects','Bodies','Scenes','Scrambled')

# ---- assemble rows: Experiment, Condition, DS1..DS6, Total ----
rows <- list()
addrow <- function(expname, cond, v)
  rows[[length(rows)+1]] <<- data.frame(Experiment=expname, Condition=cond,
      as.list(v), Total=sum(v), check.names=FALSE, stringsAsFactors=FALSE)

for (c in dcond) addrow('Dynamic Face Localizer (≥2 runs)', c, dyloc_by_cond(ge2, c))
addrow('Dynamic Face Localizer (1 run only)',
       paste(dcond, collapse='; '), dyloc_by_cond(one, 'Faces'))
addrow('ToM Loc',          'False Belief; False Photo',                                   other_exp('tom'))
addrow('Lang Loc',         'Words; Nonsense',                                             other_exp('lang2cond'))
addrow('Voice Loc',        'Vocal; Nonvocal',                                             other_exp('tva'))
addrow('PLWs',             'Interacting; Noninteracting',                                 other_exp('plw'))
addrow('Animate Agents',   'Help; Hinder; Animate; Inanimate',                            other_exp('shape'))
addrow('Story Listening',  'Theory of Mind; Body Motion; Object Motion; Object No Motion; Jabberwocky; Music', other_exp('mega'))
addrow('PLDs',             'Biological Motion; Biological Scrambled; Linear Motion; Rigid Object Motion; Object Scrambled; Static', other_exp('bio'))
addrow('Gestures',         'Speech No Video; Gesture & Speech; Gesture & Silence; Groom & Speech; Groom & Silence', other_exp('gesture'))
addrow('Social Inference', 'Male Positive; Male Negative; Female Positive; Female Negative; Social Inclusion; Social Exclusion; Agent Success; Agent Fail', other_exp('eib1'))

tab <- do.call(rbind, rows)

# ---- flextable, matching the contrast-table styling ----
ft <- flextable(tab) %>%
  merge_v(j = "Experiment") %>%
  align(j = c("Experiment","Condition"), align = "left",   part = "all") %>%
  align(j = c(DScols,"Total"),           align = "center", part = "all") %>%
  valign(j = "Experiment", valign = "top", part = "body") %>%
  theme_booktabs() %>%
  bold(part = "header") %>%
  fontsize(size = 9, part = "all") %>%
  font(fontname = "Garamond", part = "all") %>%
  padding(padding = 2, part = "all")

# fixed widths (inches); fits A4 with 1" margins (usable ~6.26")
ft <- width(ft, j = "Experiment", width = 1.35)
ft <- width(ft, j = "Condition",  width = 2.50)
for (d in DScols) ft <- width(ft, j = d, width = 0.33)
ft <- width(ft, j = "Total", width = 0.40)
ft <- set_table_properties(ft, layout = "fixed")

doc <- read_docx() %>% body_add_flextable(ft) %>%
  body_set_default_section(prop_section(
    page_size    = page_size(width = 12240/1440, height = 15840/1440, orient = "portrait"),  # US Letter
    page_margins = page_mar(top = 1, bottom = 1, left = 1, right = 1)))
print(doc, target = paste0(resultsDir, "TableS01_participants.docx"))
message("wrote ", resultsDir, "TableS01_participants.docx")
if (file.exists("Rplots.pdf")) invisible(file.remove("Rplots.pdf"))
