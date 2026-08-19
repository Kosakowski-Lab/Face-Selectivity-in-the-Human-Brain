clear all
close all
clc

% make impulse nuisance regressors for high-motion TPs

startDir = '/PATH/TO';

studies = {'deen2015' 'isik2017' 'skerry2014' 'EvLab'};
subjStr = {'SAX*' 'KAN*' 'SAX*' 'sub*'};
exps = {{'bio' 'mega' 'tom' 'tva'} ... % deen2015
    {'plw' 'shape' 'tom'} ... % isik2017
    {'eib1' 'eib2' 'tom'} ... % skerry2014
    {'gesture'}}; % EvLab
paras = {{'bio.para' 'mega.para' 'tom.para' 'tva.para'} ...
    {'plw.para' 'shape.para' 'tom.para'} ...
    {'eib1.para' 'eib2.para' 'tom.para'} ...
    {'gest.para'}};
runLists = {{'bioRuns' 'megaRuns' 'tomRuns' 'tvaRuns'} ...
    {'plwRuns' 'shapeRuns' 'tomRuns'} ...
    {'eib1Runs' 'eib2Runs' 'tomRuns'} ...
    {'gestRuns'}};
subjLists = {{'bioSubjs' 'megaSubjs' 'tomSubjs' 'tvaSubjs'} ...
    {'plwSubjs' 'shapeSubjs' 'tomSubjs'} ...
    {'eib1Subjs' 'eib2Subjs' 'tomSubjs'} ...
    {'gestSubjs'}};
blockDurs = {[20.25 9 2 2] [16 12 4] [3 3 12] 10.5};
nConds = {[6 6 14 16] [2 4 12] [8 4 4] 5};
hemis = {'rh' 'lh'};
tr = 2;

for iStudy = 3
    for iExp = 1:length(exps{iStudy})
        e = exps{iStudy}{iExp};
        rList = runLists{iStudy}{iExp};
        studyDir = [startDir filesep studies{iStudy} filesep e];
        % get the subject list
        subjs = dir([studyDir filesep subjStr{iStudy}]); subjs = {subjs.name}';
        for iSubj = 1:length(subjs)
            subjDir = [studyDir filesep subjs{iSubj} filesep 'bold'];
            fn = [subjDir filesep rList];
            fid = fopen(fn);
            bolds = textscan(fid,'%s'); bolds = bolds{1};
            fclose(fid);
            for iRun = 1:length(bolds)
                boldDir = [subjDir filesep bolds{iRun}];
                newFN = [boldDir filesep 'exTPs.txt'];
                if exist(newFN,'file')
                    system(['rm ' newFN]);
                end
                mcFN = [boldDir filesep 'fmcpr.mcdat'];
                mcDat = readmatrix(mcFN,'FileType','text');
                mc = mcDat(:,2:7);
                diff = mc(2:end,:)-mc(1:end-1,:);
                % timepoints start at 0, not 1
                ex = [];
                for i = 1:size(diff,1)
                    if any(diff(i,:)>0.5)
                        ex(end+1) = i;
                    end
                end
                if ~isempty(ex)
                    exTPs = ex .* tr;
                    writematrix(exTPs',newFN);
                end
            end
        end
    end
end