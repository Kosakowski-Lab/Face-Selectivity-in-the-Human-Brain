clear all
close all
clc

%%% convert MNI parcels to subject-specific %%%


% brain dir
brainDir = '/PATH/TO/brains/subjAnats';


startDir = '/PATH/TO/faces/';
load([startDir 'subj_incl_splitHalf.mat'],'inclSubjs');

% all of the subjects have the same label names so might as well pre-load
clustDir = [startDir 'overlap_sm4/oddRuns/top10/clusterSummaries/sc/thr25percent/ROIs_edits'];

% do this for all of the subjects
grps = {'cohen2019_5cond' 'cohen2019_6cond' 'deen2015' 'EvLab' 'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
strs = {'ea' 'ea' 'SAX_' 'sub' 'KAN_' 'KAN_' 'SAX_'};

for iGrp = 1:length(grps)
    grpDir = [startDir grps{iGrp} filesep 'dyLoc' filesep];
    subjs = dir([grpDir filesep strs{iGrp} '*']); subjs = {subjs.name};
    for iSubj = 1:length(subjs)
        subj = subjs{iSubj}
        
        % check to see if the subject is part of the analysis
        if ~any(strcmp(subj,inclSubjs)); continue; end
        subjDir = [grpDir filesep subj];
        
        % make a place to store the parcels
        subjRoiDir = [subjDir filesep 'rois' filesep 'FvO_edits'];
        if ~exist(subjRoiDir,'dir'); mkdir(subjRoiDir); end
        
        % get the brain information for this subject
        subjBrainDir = [brainDir filesep subj filesep 'mri'];
        subjBrainSeg = [subjBrainDir filesep 'aparc+aseg.nii.gz'];
        if ~exist(subjBrainSeg,'file')
            system(['mri_convert ' subjBrainDir filesep 'aparc+aseg.mgz ' subjBrainSeg]);
        end
        
        % convert anatomical ROIs to subject-specific space
        for iParc = 1:23
            mniFN = [clustDir filesep rois{iParc}];
            subFN = [subjRoiDir filesep rois{iParc}];
            system(['mri_label2label --srcsubject fsaverage --srclabel ' mniFN ...
                ' --trgsubject ' subj ' --trglabel ' subFN ' --regmethod surface --hemi lh']);
        end

    end
end