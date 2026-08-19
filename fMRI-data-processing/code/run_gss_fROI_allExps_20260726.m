% run_gss_fROI
% 2024.06.25
% hlk
% udpated 2026.07.27 for new parcels on new server
clear all
close all
clc
startDir = '/PATH/TO/faces/';

% wrapping through each experiment
grps = {'deen2015' 'EvLab' 'isik2017' 'skerry2014' 'cohen2019_5cond' 'cohen2019_6cond'};
strs = {'SAX_' 'sub' 'KAN_' 'SAX_' 'ea' 'ea'};

exps = {{'dyLoc' 'bio' 'mega' 'tom' 'tva'} {'dyLoc' 'gesture' 'lang2cond'} {'dyLoc' 'plw' 'shape' 'tom'} ...
    {'dyLoc' 'eib1' 'tom'} {'dyLoc'} {'dyLoc'}};

condNames = {{{'Faces' 'Bodies' 'Objects'} {'BioMot' 'BioScram' 'Coh' 'Static' 'Sfm' 'SfmScram'} ... % bio
    {'ToM' 'Bio' 'PMo' 'PNM' 'Jab' 'Mus'} {'FB' 'FP'} {'Vocal' 'nonvocal'}} ...
    {{'Faces' 'Bodies' 'Scenes' 'Objects' 'Scrambled'} {'GNA' 'GA' 'NGNA' 'NGA' 'A'} {'SENT' 'NONS'}} ...
    {{'Faces' 'Bodies' 'Scenes' 'Objects' 'Scrambled'} {'plwInt' 'plwNoInt'} {'help' 'hinder' 'noInteraction' 'physics'} {'FB' 'FP'}} ...
    {{'nan' 'nan' 'nan' 'nan' 'Faces' 'Objects'} {'mu' 'fu' 'mh' 'fh' 'nu' 'su' 'nh' 'sh'} {'FB' 'FP'}} ...
    {{'Faces' 'Bodies' 'Scenes' 'Objects' 'Scrambled'}} {{'Faces' 'Bodies' 'Scenes' 'Objects' 'Scrambled'}}};
condNums = {{1:3 1:6 1:6 1:2 1:2} {1:5 1:5 1:2} {1 1:2 1:4 1:2} {5:6 1:8 1:2} {1:5} {1:5}};

% all of the subjects have the same label names so might as well pre-load
lblDir = [startDir 'final_rois'];
LHlblDir = [lblDir filesep 'LH'];
RHlblDir = [lblDir filesep 'RH'];
lhLbls = dir([LHlblDir filesep '*.label']); lhLbls = {lhLbls.name};
rhLbls = dir([RHlblDir filesep '*.label']); rhLbls = {rhLbls.name};

% set all of the variables
nPer = 5;
con = 'FvO';
rhSelectAna = 'dyloc-surfSelf-rh-sm4-oddRuns';
alt_rhSelectAna = 'dyloc-surfSelf-rh-sm4-dylocOdd';
lhSelectAna = 'dyloc-surfSelf-lh-sm4-oddRuns';
alt_lhSelectAna = 'dyloc-surfSelf-lh-sm4-dylocOdd';

conditionCell = {};
subjectCell = {};
roiCell = {};
betaCell = [];
grpCell = {};
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
        subj = subjs{iSubj};
        % set up all of the subject-specific directories
        if iGrp == 3
            subjDir = [dylocDir2 filesep subj];
            conds{1} = 1:2;
            condNames{iGrp}{1} = {'Faces' 'Objects'};
            if ~exist(subjDir,'dir')
                subjDir = [dylocDir5 filesep subj];
                conds{1} = 1:5;
                condNames{iGrp}{1} = {'Faces' 'Bodies' 'Scenes' 'Objects' 'Scrambled'};
            end
        else
            subjDir = [dylocDir filesep subj];
        end
        lblPath = [subjDir filesep 'rois' filesep 'FvO_final'];
        boldDir = [subjDir filesep 'bold'];
        for iLbl = 1:length(lhLbls)
            lblFN = [lblPath filesep lhLbls{iLbl}];
            selectDir = [boldDir filesep lhSelectAna];
            if ~exist(selectDir,'dir')
                selectDir = [boldDir filesep alt_lhSelectAna];
            end
            if any(strcmp(subj,{'sub342' 'sub348' 'sub401' 'sub417'}))
                % these are the subjects that have only 1 dyloc run
                selectDir = [boldDir filesep 'dyloc-surfSelf-lh-sm4-dylocAll'];
            end
            if ~exist(selectDir,'dir')
                disp(['selectDir missing for ' subj]);
                disp('          selectDir:  dyloc LH  ' );
                continue
            end
            mb = gss_fROI_allExps(grpDir, subj, 'lh', selectDir, exps{iGrp}, lblFN, nPer, con, conds);
            for iExp = 1:length(exps{iGrp})
                for iCond = conds{iExp}
                    conditionCell{end+1} = condNames{iGrp}{iExp}{iCond};
                    subjectCell{end+1} = subj;
                    roiCell{end+1} = lhLbls{iLbl};
                    betaCell(end+1) = mb{iExp}(iCond);
                    grpCell{end+1} = grps{iGrp};
                    expCell{end+1} = exps{iGrp}{iExp};
                end
            end
            clear('mb');
        end
        for iLbl = 1:length(rhLbls)
            lblFN = [lblPath filesep rhLbls{iLbl}];
            selectDir = [boldDir filesep rhSelectAna];
            if ~exist(selectDir,'dir')
                selectDir = [boldDir filesep alt_rhSelectAna];
            end
            if any(strcmp(subj,{'sub342' 'sub348' 'sub401' 'sub417'}))
                % these are the subjects that have only 1 dyloc run
                selectDir = [boldDir filesep 'dyloc-surfSelf-rh-sm4-dylocAll'];
            end
            if ~exist(selectDir,'dir')
                disp(['selectDir missing for ' subj]);
                disp('          selectDir:  dyloc RH  ');
                continue
            end
            mb = gss_fROI_allExps(grpDir, subj, 'rh', selectDir, exps{iGrp}, lblFN, nPer, con, conds);
            for iExp = 1:length(exps{iGrp})
                for iCond = conds{iExp}
                    conditionCell{end+1} = condNames{iGrp}{iExp}{iCond};
                    subjectCell{end+1} = subj;
                    roiCell{end+1} = rhLbls{iLbl};
                    betaCell(end+1) = mb{iExp}(iCond);
                    grpCell{end+1} = grps{iGrp};
                    expCell{end+1} = exps{iGrp}{iExp};
                end
            end
            clear('mb');
        end
    end
end

saveDir = [startDir 'fROI'];
fn = [saveDir filesep 'gss_fROI_dyloc_FvO_allExps_' char(datetime('now'), 'yyyyMMdd') '.csv'];
tbl = cell2table([grpCell' expCell' subjectCell' roiCell' conditionCell' num2cell(betaCell)'], ...
    'VariableNames',{'group' 'experiment' 'subject' 'roi' 'condition' 'betas' });
writetable(tbl,fn);
fn = [saveDir filesep 'gss_fROI_dyloc_FvO_allExps_' char(datetime('now'), 'yyyyMMdd') '.mat'];
save(fn,'grpCell', 'expCell', 'subjectCell', 'roiCell', 'conditionCell', 'betaCell');    

