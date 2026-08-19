function permCMD = rfx_allRuns()
permCMD = {};
startDir = '/PATH/TO/faces';
con = 'FvO';
hemis = {'lh' 'rh'};
allGrps = {'cohen2019_5cond' 'cohen2019_6cond' 'deen2015' 'EvLab' 'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
strs = {'ea' 'ea' 'SAX_' 'sub' 'KAN_' 'KAN_' 'SAX_'};

% make a place to store the data for RFX of all data
allDir = [startDir filesep 'rfx_sm4' filesep 'allRuns' filesep con];
allLHdir = [allDir filesep 'lh' filesep 'conImgs'];
allRHdir =  [allDir filesep 'rh' filesep 'conImgs'];
if ~exist(allDir,'dir'); mkdir(allDir); end
if ~exist(allLHdir,'dir'); mkdir(allLHdir); end
if ~exist(allRHdir,'dir'); mkdir(allRHdir); end
% make a place to store data for only Skerry RFX
skerryDir = [startDir filesep 'rfx_sm4' filesep 'skerryAllRuns' filesep con];
skerryLHdir = [skerryDir filesep 'lh' filesep 'conImgs'];
skerryRHdir =  [skerryDir filesep 'rh' filesep 'conImgs'];
if ~exist(skerryDir,'dir'); mkdir(skerryDir); end
if ~exist(skerryLHdir,'dir'); mkdir(skerryLHdir); end
if ~exist(skerryRHdir,'dir'); mkdir(skerryRHdir); end
% first, we need to get all of the coontrast maps into the same spot
for iStudy = 1:length(allGrps)
    studyDir = [startDir filesep allGrps{iStudy} filesep 'dyLoc'];
    subjs = dir([studyDir filesep strs{iStudy} '*']); subjs = {subjs.name};
    for iSubj = 1:length(subjs)
        subj = subjs{iSubj}
        for iHemi = 1:length(hemis)
            if iHemi == 1
                hemiDir = allLHdir;
                skerryHemiDir = skerryLHdir;
            else
                hemiDir = allRHdir;
                skerryHemiDir = skerryRHdir;
            end
            h = hemis{iHemi}
            subjDir = [studyDir filesep subj filesep 'bold' filesep 'dyloc-fsSurf-' h '-sm4' filesep con];
            if ~exist(subjDir,'dir')
                subjDir = [studyDir filesep subj filesep 'bold' filesep 'dyloc-fsSurf-' h '-sm4-dylocAll' filesep con];
            end
            if ~exist(subjDir,'dir')
                error(['missing directory for ' subj]);
            end
            subjCon = [subjDir filesep 'ces.nii.gz'];
            newCon = [hemiDir filesep h '-' con '-' subj '-ces.nii.gz'];
            system(['cp ' subjCon ' ' newCon]);
            if iStudy==length(allGrps)
                skerryCon = [skerryHemiDir filesep h '-' con '-' subj '-ces.nii.gz'];
                system(['cp ' subjCon ' ' skerryCon]);
            end
        end
    end
end
% okay, now that we have all of the contrast maps in the right spot, we can do the RFX
for iHemi = 1:length(hemis)
    hemi = hemis{iHemi};
    hemiDir = [allDir filesep hemi];
    % run the rfx
    runRFX(hemiDir,hemi,5000,2,con);
    hemiDir = [skerryDir filesep hemi];
    % run the rfx
    runRFX(hemiDir,hemi,5000,2,con);
end
