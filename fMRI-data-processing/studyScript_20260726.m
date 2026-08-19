clear all
close all
clc

startDir = '/PATH/TO/faces';
addpath(genpath([startDir filesep 'code']));
addpath(fullfile(getenv('FREESURFER_HOME'), 'matlab'))

% preprocess the data
run_run_preprocess.sh

% make timepoint exclusion files
makeImpFiles_dyLoc
makeImpFiles_nonDyLoc

% 1. set up the GLMs for dyloc and non-dyloc paradigms
      setAnalyses_dyLoc_sm4.m
      setAnalyses_nonDyLoc_sm4.m
      run_dyloc_allCons_EvLab.sh
          singleSubjectGLM_dyLoc_allCons.sh
          singleSubjectGLM_gesture.sh
      run_dyloc_allCons_Skerry.sh
          singleSubjectGLM_dyLoc_faces_skerry.sh
          singleSubjectGLM_eib1.sh 
          singleSubjectGLM_tom.sh 

% 2. run RFX on all subjects 
      rfx_splitHalf.m

% 3. run a split-half analysis:

%       (a) for each subject that has more than one run, split their data in half.
%           findSplitHalf.m
%       (b) use use odd runs --> overlap analysis 
%       (c) use odd runs --> select voxels
%       (d) use even runs --> extract beta values

% 4. reliability of split-half analysis:
%       (e) use use even runs --> overlap analysis 
%       (f) use even runs --> select voxels
%       (g) use odd runs --> extract beta values
%       (h) plot all betas --> even vs odd --> should be perfectly correlated

%%%%%%%  find the subjects that have at least two runs and create run and subject lists
[exSubjs, inclSubjs, nRuns] = findSplitHalf();
save([startDir filesep 'subj_incl_splitHalf.mat'],'exSubjs','inclSubjs','nRuns');

%%%%%%%  run analysis on each data split
setAnalyses_dyLoc_sm4_splitHalf
run_dyloc_faces.sh
run_dyloc_allCons.sh

%%%%%%%  run overlap maps
missingSubjs = getZmaps_4overlap;
disp('....missing subjects....')
missingSubjs'
[missingSubjs_top10,allVert_top10, maxVert_top10, minVert_top10] = gssOverlap(10);
[missingSubjs_top20,allVert_top20, maxVert_top20, minVert_top20] = gssOverlap(20);
save('overlapAnalysis.mat','allVert_top10','maxVert_top10','minVert_top10', ...
    'allVert_top20','maxVert_top20','minVert_top20','missingSubjs_top10','missingSubjs_top20');

%%%%%%% get cluster summaries & make annotation files
group_cluster_summary_4_topN(10)
make_annot_file(10)


%%%%%%% to make the parcels, we are using top 10% of vertices per subjects
%%%%%%% with a threshold overlap of 45%. Then, we are hand-drawing obvious
%%%%%%% splits. only parcels with at least 100 vertices will be included
make_annot_handEdits;


%%%%%%% run RFX on the full dataset
rfx_allRuns
rfx_allRuns_volume

%%%%%% okay, now we are going to run the fROI analysis --> select the top
%%%%%% 5% of voxels from odd runs and then extract the betas from even
%%%%%% runs. 
% convert labels to subject-specific space
annot2subjLabels_20240625;

% extract betas (odd runs to select, even runs only for dyloc, all runs for
% all other experiments)
run_gss_fROI_allExps_20260726

%%%%%%% run the subcortical fROI analysis
getZmaps_4overlap_volume
gssOverlap_volume(10);
group_cluster_summary_4_topN_vol(10);
make_vol_rois(10,45);
make_vol_rois(10,25);
make_mni_parcels;

% not all of the BOLD data is in the same space for each subjects so we
% need to fix that...
% going to fix this by doing the analysis in MNI space (I tried native
% space but there were so many work-arounds required that MNI space makes
% more sense. 

%%% make the ROIs %%%

% we are using 
% top 10, 30%
% 9 - thalamus 
% 18 - superior colliculus 
% 5 - cerebellum
% 3 - cerebellum
% 7 - cerebellum
% 11 - cerebellum

% aparc & aseg
% right posterior hippocampus
% left posterior hippocampus
% 50 - right cauudate
% 11 - left caudate
% 51 - right putamen
% 12 - left putamen
% 13 - left pallidum
% 52 - rigth pallidum
% 28 - left ventral DC
% 60 - right ventral DC
% 54 - right amygdala
% 18 - left amygdala
% 26 - left accumbens area
% 58 - right accumbens area

parcDir = '';
parcs = dir([parcDir filesep '*.nii.gz']); parcs = {parcs.name};
for iParc = 1:length(parcs)
    parcName = [parcDir filesep parcs{iParc}];
    cmd = ['fslmaths ' parcName ' -bin ' parcName];
    system(cmd);
    newName = [parcName(1:end-7) '_dilm1.nii.gz'];
    cmd = ['fslmaths ' parcName ' -bin -dilM -fillh -bin ' newName];
    system(cmd);
    newName2 = [parcName(1:end-7) '_dilm2.nii.gz'];
    cmd = ['fslmaths ' newName ' -bin -dilM -fillh -bin ' newName2];
    system(cmd);
end

% conduct standard fROI analysis 
run_gss_fROI_volume;

% get a GLM for all of the other experiments in MNI space
run_glm_MNI_20250916;

% now run the fROI analysis for all of the other experiments
run_gss_fROI_allExps_volume_20260726;

