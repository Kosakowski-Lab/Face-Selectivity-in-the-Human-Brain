function [missingSubjs] = getZmaps_4overlap_volume()

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
        str = 'dyloc-mni305-2mm-sm4-dylocOdd';
        volDir = [overlapDir filesep 'oddRuns' filesep 'zMaps' filesep 'subCtx'];
    else
        str = 'dyloc-mni305-2mm-sm4-dylocEven';
        volDir = [overlapDir filesep 'evenRuns' filesep 'zMaps' filesep 'subCtx'];
    end
    if ~exist(volDir,'dir'); mkdir(volDir); end
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
        volZ = [subjDir str filesep con filesep 'z.nii.gz'];
        newZ = [volDir filesep 'sc-' con '-' subj '-z.nii.gz'];
        system(['cp ' volZ ' ' newZ]);
        end
    end
end