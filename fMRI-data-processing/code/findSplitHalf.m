function [exSubjs, inclSubjs, nRuns] = findSplitHalf()

startDir = '/PATH/TO/faces';
groups = {'cohen2019_5cond' 'cohen2019_6cond' 'deen2015' 'EvLab' ...
    'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
sStr = {'ea' 'ea' 'SAX_mega' 'sub' 'KAN_SOC' 'KAN_SOC' 'SAX_EIB'};

% find our splits for each participant
exSubjs = {};
inclSubjs = {};
nRuns = [];
for iGrp =  1:length(groups)
    inclSubjsGrp = {};
    grpDir = [startDir filesep groups{iGrp} filesep 'dyLoc'];
    subjs = dir([grpDir filesep sStr{iGrp} '*']); subjs = {subjs.name};
    for iSubj = 1:length(subjs)
        subjDir = [grpDir filesep subjs{iSubj} filesep 'bold'];
        b0 = dir([subjDir filesep '0*']);
        b1 = dir([subjDir filesep '1*']);
        b2 = dir([subjDir filesep '2*']);
        b3 = dir([subjDir filesep '3*']);
        b4 = dir([subjDir filesep '4*']);
        b5 = dir([subjDir filesep '5*']);
        b6 = dir([subjDir filesep '6*']);
        b7 = dir([subjDir filesep '7*']);
        bolds = {b0.name b1.name b2.name b3.name b4.name b5.name b6.name b7.name};
        bolds'
        if length(bolds) <= 1
            exSubjs{end+1} = subjs{iSubj};
        else
            inclSubjs{end+1} = subjs{iSubj};
            inclSubjsGrp{end+1} = subjs{iSubj};
            nRuns(end+1) = length(bolds);
%             oddRuns = bolds(1:2:end);
%             evenRuns = bolds(2:2:end);
%             fnEven = [subjDir filesep 'dylocEven'];
%             fnOdd = [subjDir filesep 'dylocOdd'];
%             writecell(oddRuns',fnOdd);
%             writecell(evenRuns',fnEven);
%             system(['mv ' fnEven '.txt ' fnEven]);
%             system(['mv ' fnOdd '.txt ' fnOdd]);
        end
    end
%     analysisDir = [startDir filesep groups{iGrp} filesep 'dyLoc' filesep 'analysis'];
%     grpListFN = [analysisDir filesep 'dylocSplitHalf'];
%     writecell(inclSubjsGrp',grpListFN);
%     system(['mv ' grpListFN '.txt ' grpListFN]);
end