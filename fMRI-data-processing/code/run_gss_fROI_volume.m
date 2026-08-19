% run_gss_fROI
% 2024.06.25
% hlk
% updated to run on the volume
% 2025.09.13
% hlk

clear all
close all
clc

startDir = '/PATH/TO/faces/';

% make sure we include the correct subjects
load([startDir 'subj_incl_splitHalf.mat'],'inclSubjs');

% wrapping through each experiment
grps = {'cohen2019_5cond' 'cohen2019_6cond' 'deen2015' 'EvLab' 'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
strs = {'ea' 'ea' 'SAX_' 'sub' 'KAN_' 'KAN_' 'SAX_'};
nConds = {1:5 1:5 1:3 1:5 1:2 1:5 5:6};
condOrder = {1:5 1:5 [1 2 4] 1:5 [1 4] 1:5 [1 4]};

% set all of the variables
nPer = 5;
con = 'FvO';
selectAna = 'dyloc-mni305-2mm-sm4-dylocOdd';
extractAna = 'dyloc-mni305-2mm-sm4-dylocEven';
allSubjs = {};

% get all of the ROIs
parcDir = [startDir 'overlap_sm4/oddRuns/top10/subCtx_parcels'];
parcs = dir([parcDir filesep '*_dilm1.nii.gz']); parcs = {parcs.name};
for iParc = 1:length(parcs)
    parcFN = [parcDir filesep parcs{iParc}];
    parc = MRIread(parcFN);
    parcVecs(iParc,:) = reshape(parc.vol,[1,numel(parc.vol)]);
    parcNames{iParc} = parcs{iParc}(9:end-13);
end
allSubjs = {};
allParcs = {};
meanIndBetas = [];
meanNIbetas = [];
for iGrp = 1:length(grps)
    grpDir = [startDir grps{iGrp} filesep 'dyLoc'];
    conds = nConds{iGrp};
    co = condOrder{iGrp};
    subjs = dir([grpDir filesep strs{iGrp} '*']); subjs = {subjs.name};
    idx = 0;
    for iSubj = 1:length(subjs)
        subj = subjs{iSubj}
        % check to see if the subject is part of the analysis, if not continue
        if ~any(strcmp(subj,inclSubjs)); continue; end
        idx = idx + 1;
        % set up all of the subject-specific directories
        subjDir = [grpDir filesep subj];
        boldDir = [subjDir filesep 'bold'];
        selectDir = [boldDir filesep selectAna];
        extractDir = [boldDir filesep extractAna];
        [subjCell, parcCell, indMat, niMat] = gss_fROI_volume(subj, selectDir, extractDir, parcVecs, parcNames, nPer, conds, con, co);
        allSubjs = [allSubjs subjCell];
        allParcs = [allParcs parcCell];
        meanIndBetas = [meanIndBetas; indMat];
        meanNIbetas = [meanNIbetas; niMat];
        clear('subjCell','parcCell','indMat','niMat');
    end
end
saveDir = [startDir filesep 'fROI'];
fn = [saveDir filesep 'gss_fROI_dyloc_FvO_MNI_' date '.mat'];
save(fn,'meanIndBetas','allSubjs','meanNIbetas','allParcs');



condNames = {'faces' 'bodies' 'scenes' 'objects' 'scrambled'};
condition = {};
subject = {};
roi = {};
indBeta = [];
niBeta = [];
fac = [];
bod = [];
obj = [];
scn = [];
scr = [];
for i = 1:length(allSubjs)
    for c = 1:5
        subject{end+1} = allSubjs{i};
        roi{end+1} = allParcs{i};
        condition{end+1} = condNames{c};
        indBeta(end+1) = meanIndBetas(i,c);
        niBeta(end+1) = meanNIbetas(i,c);
        if c == 1
            fac(end+1) = 1;
            bod(end+1) = 0;
            obj(end+1) = 0;
            scn(end+1) = 0;
            scr(end+1) = 0;
        elseif c == 2
            fac(end+1) = 0;
            bod(end+1) = 1;
            obj(end+1) = 0;
            scn(end+1) = 0;
            scr(end+1) = 0;
        elseif c == 3
            fac(end+1) = 0;
            bod(end+1) = 0;
            obj(end+1) = 1;
            scn(end+1) = 0;
            scr(end+1) = 0;
        elseif c == 4
            fac(end+1) = 0;
            bod(end+1) = 0;
            obj(end+1) = 0;
            scn(end+1) = 1;
            scr(end+1) = 0;
        elseif c == 5
            fac(end+1) = 0;
            bod(end+1) = 0;
            obj(end+1) = 0;
            scn(end+1) = 0;
            scr(end+1) = 1;
        end
    end
end
fn = [saveDir filesep 'gss_fROI_dyloc_FvO_volume_' date '.csv'];
tbl = cell2table([subject' roi' condition' num2cell(indBeta)' num2cell(niBeta)' ...
    num2cell(fac)' num2cell(bod)' num2cell(obj)' num2cell(scn)' num2cell(scr)'], ...
    'VariableNames',{'subject' 'roi' 'condition' 'indBeta' 'niBeta' ...
    'fac' 'bod' 'obj' 'scn' 'scr'});
writetable(tbl,fn);






