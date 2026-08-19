function [missingSubjs] = getZmaps_4overlap()

startDir = '/PATH/TO/faces';
con = 'FvO';

% make a directory for the analyses
overlapDir = [startDir filesep 'overlap_sm4'];
if ~exist(overlapDir,'dir'); mkdir(overlapDir); end

% load the information about the subjects to include
load([startDir filesep 'subj_incl_splitHalf.mat']);

%%%%%%%%%%%%%%%%% copy over all of the z-maps %%%%%%%%%%%%%%%%%
% set the directories for all of the contrast maps
c5dir = [startDir filesep 'cohen2019_5cond' filesep 'dyLoc'];
c6dir = [startDir filesep 'cohen2019_6cond' filesep 'dyLoc'];
dDir = [startDir filesep 'deen2015' filesep 'dyLoc'];
i2dir = [startDir filesep 'isik2017_2cond' filesep 'dyLoc'];
i5dir = [startDir filesep 'isik2017_5cond' filesep 'dyLoc'];
eDir = [startDir filesep 'EvLab' filesep 'dyLoc'];
missingSubjs = {};
% run for each data split
for iSplit = 1:2
    if iSplit == 1
        lhStr = 'dyloc-fsSurf-lh-sm4-oddRuns';
        rhStr = 'dyloc-fsSurf-rh-sm4-oddRuns';
        lhDir = [overlapDir filesep 'oddRuns' filesep 'zMaps' filesep 'lh'];
        rhDir = [overlapDir filesep 'oddRuns' filesep 'zMaps' filesep 'rh'];
        lhAlt = 'dyloc-fsSurf-lh-sm4-dylocOdd';
        rhAlt = 'dyloc-fsSurf-rh-sm4-dylocOdd';
    else
        lhStr = 'dyloc-fsSurf-lh-sm4-evenRuns';
        rhStr = 'dyloc-fsSurf-rh-sm4-evenRuns';
        lhDir = [overlapDir filesep 'evenRuns' filesep 'zMaps' filesep 'lh'];
        rhDir = [overlapDir filesep 'evenRuns' filesep 'zMaps' filesep 'rh'];
        lhAlt = 'dyloc-fsSurf-lh-sm4-dylocEven';
        rhAlt = 'dyloc-fsSurf-rh-sm4-dylocEven';
    end
    if ~exist(lhDir,'dir'); mkdir(lhDir); end
    if ~exist(rhDir,'dir'); mkdir(rhDir); end
    for iSubj = 1:length(inclSubjs)
        % first, find the subject's analysis directory
        subj = inclSubjs{iSubj}
        if strncmp('ea',subj,2)
            subjDir = [c5dir filesep subj filesep 'bold' filesep];
            if ~exist(subjDir,'dir')
                subjDir = [c6dir filesep subj filesep 'bold' filesep];
            end
        elseif strncmp('SAX_mega',subj,8)
            subjDir = [dDir filesep subj filesep 'bold' filesep];
        elseif strncmp('KAN_SOC',subj,7)
            subjDir = [i2dir filesep subj filesep 'bold' filesep];
            if ~exist(subjDir,'dir')
                subjDir = [i5dir filesep subj filesep 'bold' filesep];
            end
        elseif strncmp('sub',subj,3)
            subjDir = [eDir filesep subj filesep 'bold' filesep];
        end
        if ~exist(subjDir,'dir')
            disp(['problem finding analysis directory for ' subj]);
            missingSubjs{end+1} = subj;
        else
        % now get the z-maps and copy them to the correct directory
        lhZ = [subjDir lhStr filesep con filesep 'z.nii.gz'];
        rhZ = [subjDir rhStr filesep con filesep 'z.nii.gz'];
        if ~exist(lhZ,'file') ||  ~exist(lhZ,'file')
            lhZ = [subjDir lhAlt filesep con filesep 'z.nii.gz'];
            rhZ = [subjDir rhAlt filesep con filesep 'z.nii.gz'];
        end
        newLH = [lhDir filesep 'lh-' con '-' subj '-z.nii.gz'];
        newRH = [rhDir filesep 'rh-' con '-' subj '-z.nii.gz'];
        system(['cp ' lhZ ' ' newLH]);
        system(['cp ' rhZ ' ' newRH]);
        end
    end
end