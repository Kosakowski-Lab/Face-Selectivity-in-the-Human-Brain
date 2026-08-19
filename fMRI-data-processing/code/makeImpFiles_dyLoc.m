clear all
close all
clc

% make impulse nuisance regressors for high-motion TPs

startDir = '/PATH/TO';

grps = {'EvLab' 'cohen2019_5cond' 'cohen2019_6cond' 'cohen2019_kids' ...
    'deen2015' 'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
subjStrs = {'sub*' 'ea*' 'ea*' 'ek*' 'SAX*' 'KAN*' 'KAN*' 'SAX*'};
tr = 2;
exSubjs = {};
exRuns = {};
for iGrp = length(grps)
    grpDir = [startDir filesep grps{iGrp} filesep 'dyLoc'];
    subjs = dir([grpDir filesep subjStrs{iGrp}]); subjs = {subjs.name}';
    for iSubj = 1:length(subjs)
        subjDir = [grpDir filesep subjs{iSubj} filesep 'bold'];
        fn = [subjDir filesep 'dylocAllRuns'];
        if ~exist(fn,'file'); continue; end
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
            if ~exist(mcFN,'file')
                disp(['problem with motion correction for subj ' subjs{iSubj} ' run ' bolds{iRun}]);
                disp(' ');
                continue
            end
            mcDat = readmatrix(mcFN,'FileType','text');
            mc = mcDat(:,2:7);
            diff = mc(2:end,:)-mc(1:end-1,:);
            % runs to exclude
            if any(any(diff>2))
                disp(['exclude subject ' subjs{iSubj} ' run ' bolds{iRun}]); disp(' ');
                exSubjs{end+1} = subjs{iSubj};
                exRuns{end+1} = bolds{iRun};
            end
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