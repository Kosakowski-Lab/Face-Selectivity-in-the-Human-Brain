function permCMD = rfx_allRuns_volume()
clc
permCMD = {};
startDir = '/PATH/TO/faces';
con = 'FvO';
allGrps = {'cohen2019_5cond' 'cohen2019_6cond' 'deen2015' 'EvLab' 'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
strs = {'ea' 'ea' 'SAX_' 'sub' 'KAN_' 'KAN_' 'SAX_'};

% make a place to store the data for RFX of all data
allDir = [startDir filesep 'rfx_sm2' filesep 'allRuns' filesep con];
allMNIdir = [allDir filesep 'mni' filesep 'conImgs'];
if ~exist(allDir,'dir'); mkdir(allDir); end
if ~exist(allMNIdir,'dir'); mkdir(allMNIdir); end
% make a place to store data for only Skerry RFX
skerryDir = [startDir filesep 'rfx_sm2' filesep 'skerryAllRuns' filesep con];
skerryMNIdir = [skerryDir filesep 'mni' filesep 'conImgs'];
if ~exist(skerryDir,'dir'); mkdir(skerryDir); end
if ~exist(skerryMNIdir,'dir'); mkdir(skerryMNIdir); end

% first, we need to get all of the coontrast maps into the same spot
for iStudy = 1:length(allGrps)
    studyDir = [startDir filesep allGrps{iStudy} filesep 'dyLoc'];
    subjs = dir([studyDir filesep strs{iStudy} '*']); subjs = {subjs.name};
    for iSubj = 1:length(subjs)
        subj = subjs{iSubj}
        subjDir = [studyDir filesep subj filesep 'bold' filesep 'dyloc-mni305-2mm-sm2-wBrain-dylocAll' filesep con];
        if ~exist(subjDir,'dir')
            error(['missing directory for ' subj]);
        end
        subjCon = [subjDir filesep 'ces.nii.gz'];
        newCon = [allMNIdir filesep 'mni2mm-' con '-' subj '-ces.nii.gz'];
        system(['cp ' subjCon ' ' newCon]);
%         if iStudy==length(allGrps)
%             skerryCon = [skerryMNIdir filesep 'mni2mm-' con '-' subj '-ces.nii.gz'];
%             system(['cp ' subjCon ' ' skerryCon]);
%         end
    end
end

% okay, now that we have all of the contrast maps in the right spot, we can do the RFX
% run the rfx
conDir = [allDir filesep 'mni'];
runRFX(conDir,'mni',5000,2,con);
% % run the rfx
% conDir = [skerryDir filesep 'mni'];
% runRFX(conDir,'mni',5000,2,con);

