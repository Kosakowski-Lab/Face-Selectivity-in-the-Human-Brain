function [missingSubjs,allVertVals, maxVertVal, minVertVal] = gssOverlap(n)

startDir = '/PATH/TO/faces';
con = 'FvO';

% make a directory for the analyses
overlapDir = [startDir filesep 'overlap_sm4'];
if ~exist(overlapDir,'dir'); mkdir(overlapDir); end

% load the information about the subjects to include
load([startDir filesep 'subj_incl_splitHalf.mat'],'inclSubjs');

%%%%%%%%%%%%%%%%% find the top n% of vertices %%%%%%%%%%%%%%%%%

splits = {'oddRuns' 'evenRuns'};
missingSubjs = {};
% for each half of data
for iSplit = 1:length(splits)
    lhZdir = [overlapDir filesep splits{iSplit} filesep 'zMaps' filesep 'lh'];
    rhZdir = [overlapDir filesep splits{iSplit} filesep 'zMaps' filesep 'rh'];
    lhTopDir = [overlapDir filesep splits{iSplit} filesep 'top' num2str(n) filesep 'lh'];
    rhTopDir = [overlapDir filesep splits{iSplit} filesep 'top' num2str(n) filesep 'rh'];
    if ~exist(lhTopDir,'dir'); mkdir(lhTopDir); end
    if ~exist(rhTopDir,'dir'); mkdir(rhTopDir); end
    for iSubj = 1:length(inclSubjs)
        subj = inclSubjs{iSubj}
        lhFN = [lhZdir filesep 'lh-' con '-' subj '-z.nii.gz'];
        rhFN = [rhZdir filesep 'rh-' con '-' subj '-z.nii.gz'];
        if ~exist(lhFN,'file') || ~exist(rhFN,'file')
            missingSubjs{end+1} = inclSubjs{iSubj};
        else
            lhImg = MRIread(lhFN);
            rhImg = MRIread(rhFN);
            allVert = [lhImg.vol rhImg.vol];
            [vertVals, vertID] = sort(allVert,'descend');
            nVert = round(length(vertVals)*n/100);
            allVertVals{iSubj} = vertVals(1:nVert);
            maxVertVal(iSubj) = max(vertVals(1:nVert));
            minVertVal(iSubj) = min(vertVals(1:nVert));
            topVert = zeros(size(allVert));
            topVert(vertID(1:nVert)) = 1;
            topLH = topVert(1:length(lhImg.vol));
            topRH = topVert(length(lhImg.vol)+1:end);
            lhImg.vol = topLH;
            rhImg.vol = topRH;
            newLH = [lhTopDir filesep 'lh-' con '-' subj '-top' num2str(n) 'percent.nii.gz'];
            newRH = [rhTopDir filesep 'rh-' con '-' subj '-top' num2str(n) 'percent.nii.gz'];
            MRIwrite(lhImg,newLH);
            MRIwrite(rhImg,newRH);
        end
    end
end

%%%%%%%%%%%%%%%%% compute overlap (sum & proportion) %%%%%%%%%%%%%%%%%

hemis = {'lh' 'rh'};
for iSplit = 1:length(splits)
    topNdir = [overlapDir filesep splits{iSplit} filesep 'top' num2str(n)];
    for iHemi = 1:length(hemis)
        hDir = [topNdir filesep hemis{iHemi}];
        sumImg = [topNdir filesep hemis{iHemi} '-allSubjs-' con '-top' num2str(n) 'percent-fsaverage_sum.nii.gz'];
        propImg = [topNdir filesep hemis{iHemi} '-allSubjs-' con '-top' num2str(n) 'percent-fsaverage_prop.nii.gz'];
        imgs = dir([hDir filesep hemis{iHemi} '*top' num2str(n) 'percent.nii.gz']);
        imgs = {imgs.name};
        cmd = ['fslmaths ' hDir filesep imgs{1} ];
        for iImg = 2:length(imgs)
            cmd = [cmd ' -add ' hDir filesep imgs{iImg}];
        end
        cmd = [cmd ' ' sumImg];
        system(cmd);
        cmd2 = ['fslmaths ' sumImg ' -div ' num2str(length(imgs)) ' ' propImg];
        system(cmd2);
    end
end








