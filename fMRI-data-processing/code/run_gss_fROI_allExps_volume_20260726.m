% run_gss_fROI
% 2024.06.25
% hlk
% updaed for volume fROI analysis
% 2025.09.16
% hlk
clear all
close all
clc

% wrapping through each experiment
grps = {'deen2015' 'EvLab' 'isik2017' 'skerry2014'};
strs = {'SAX_' 'sub' 'KAN_' 'SAX_'};

exps = {{'bio' 'mega' 'tom' 'tva'} {'gesture' 'lang2cond'} {'plw' 'shape' 'tom'} ...
    {'eib1' 'tom'}};

condNames = {{{'BioMot' 'BioScram' 'Coh' 'Static' 'Sfm' 'SfmScram'} ... % bio
    {'ToM' 'Bio' 'PMo' 'PNM' 'Jab' 'Mus'} {'FB' 'FP'} {'Vocal' 'nonvocal'}} ...
    {{'GNA' 'GA' 'NGNA' 'NGA' 'A'} {'SENT' 'NONS'}} ...
    {{'plwInt' 'plwNoInt'} {'help' 'hinder' 'noInteraction' 'physics'} {'FB' 'FP'}} ...
    {{'mu' 'fu' 'mh' 'fh' 'nu' 'su' 'nh' 'sh'} {'FB' 'FP'}}};
condNums = {{1:6 1:6 1:2 1:2} {1:5 1:2} {1:2 1:4 1:2} {1:8 1:2}};

% get all of the ROIs
startDir = '/PATH/TO/faces/';
parcDir = [startDir 'overlap_sm4/oddRuns/top10/subCtx_parcels'];
parcs = dir([parcDir filesep '*_dilm1.nii.gz']); parcs = {parcs.name};
for iParc = 1:length(parcs)
    parcFN = [parcDir filesep parcs{iParc}];
    parc = MRIread(parcFN);
    parcVecs(iParc,:) = reshape(parc.vol,[1,numel(parc.vol)]);
    parcNames{iParc} = parcs{iParc}(9:end-13);
end

% set all of the variables
nPer = 5;
con = 'FvO';
selectAna = 'dyloc-mni305-2mm-sm4-dylocOdd';
extractAna = 'dyloc-mni305-2mm-sm4-dylocEven';
allSubjs = {};
conditionCell = {};
subjectCell = {};
roiCell = {};
betaMat = [];
grpCell = {};
missingSubjs = {};
expCell = {};
for iGrp = 1:length(grps)
    grpDir = [startDir grps{iGrp}];
    if iGrp == 3
        dylocDir2 = [grpDir '_2cond' filesep 'dyLoc'];
        dylocDir5 = [grpDir '_5cond' filesep 'dyLoc'];
        subjs2 = dir([dylocDir2 filesep strs{iGrp} '*']);
        subjs5 = dir([dylocDir5 filesep strs{iGrp} '*']);
        subjs = [{subjs5.name} {subjs2.name}];
    else
        dylocDir = [grpDir filesep 'dyLoc'];
        subjs = dir([dylocDir filesep strs{iGrp} '*']); subjs = {subjs.name};
    end
    conds = condNums{iGrp};
    for iSubj = 1:length(subjs)
        subj = subjs{iSubj}
        % set up all of the subject-specific directories
        if iGrp == 3
            subjDir = [dylocDir2 filesep subj];
            if ~exist(subjDir,'dir')
                subjDir = [dylocDir5 filesep subj];
            end
        else
            subjDir = [dylocDir filesep subj];
        end
        boldDir = [subjDir filesep 'bold'];
        if any(strcmp(subj,{'sub342' 'sub348' 'sub401' 'sub417'}))
            % these are the subjects that have only 1 dyloc run
            selectDir = [boldDir filesep 'dyloc-mni305-2mm-sm4-dylocAll'];
        else
            selectDir = [boldDir filesep selectAna];
        end
        if ~exist(selectDir,'dir')
            missingSubjs{end+1} = subj;
            continue
        end
        
        % mb has experiment for the cell, then roi x conditions within
        % each cell (i.e., for each experiment)
        mb = gss_fROI_allExps_volume(grpDir, subj, selectDir, exps{iGrp}, parcVecs, parcNames, nPer, con, conds);
        for iParc = 1:length(parcs)
            for iExp = 1:length(exps{iGrp})
                for iCond = condNums{iGrp}{iExp}
                    conditionCell{end+1} = condNames{iGrp}{iExp}{iCond};
                    subjectCell{end+1} = subj;
                    roiCell{end+1} = parcNames{iParc};
                    betaMat(end+1) = mb{iExp}(iParc,iCond);
                    grpCell{end+1} = grps{iGrp};
                    expCell{end+1} = exps{iGrp}{iExp};
                end
            end
        end
    end
end

saveDir = [startDir filesep 'fROI'];
fn = [saveDir filesep 'gss_fROI_dyloc_FvO_allExps_MNI_' char(datetime('now'), 'yyyyMMdd') '.csv'];
tbl = cell2table([grpCell' expCell' subjectCell' roiCell' conditionCell' num2cell(betaMat)'], ...
    'VariableNames',{'group' 'experiment' 'subject' 'roi' 'condition' 'betas' });
writetable(tbl,fn);
fn = [saveDir filesep 'gss_fROI_dyloc_FvO_allExps_MNI_' char(datetime('now'), 'yyyyMMdd') '.mat'];
save(fn,'grpCell', 'expCell', 'subjectCell', 'roiCell', 'conditionCell', 'betaMat');

