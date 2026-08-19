function [missingSubjs,allVoxVals, maxVoxVal, minVoxVal] = gssOverlap_volume(n)

startDir = '/PATH/TO/faces';
con = 'FvO';

% make a directory for the analyses
overlapDir = [startDir filesep 'overlap_sm4'];
if ~exist(overlapDir,'dir'); mkdir(overlapDir); end

% load the information about the subjects to include
load([startDir filesep 'subj_incl_splitHalf.mat'],'inclSubjs');

% get the MNI spaces
mniDir = '/PATH/TO/brains/subjAnats/MNI152_FS/mri';
mniFN = [mniDir filesep 'mni305-2mm-subctxmask.nii.gz'];
mniVol = MRIread(mniFN);
mniMask = reshape(mniVol.vol,[numel(mniVol.vol) 1]);


%%%%%%%%%%%%%%%%% find the top n% of vertices %%%%%%%%%%%%%%%%%

splits = {'oddRuns' 'evenRuns'};
missingSubjs = {};
% for each half of data
for iSplit = 1:length(splits)
    zDir = [overlapDir filesep splits{iSplit} filesep 'zMaps' filesep 'subCtx'];
    topDir = [overlapDir filesep splits{iSplit} filesep 'top' num2str(n) filesep 'subCtx'];
    if ~exist(topDir,'dir'); mkdir(topDir); end
    for iSubj = 1:length(inclSubjs)
        subj = inclSubjs{iSubj}
        fn = [zDir filesep 'sc-' con '-' subj '-z.nii.gz'];
        if ~exist(fn,'file') 
            missingSubjs{end+1} = inclSubjs{iSubj};
        else
            % read in the data
            volImg = MRIread(fn);
            % reshape the data to make it easier to work with
            allVox = reshape(volImg.vol, [numel(volImg.vol) 1]);
            % clear out the data in the vol matrix to use later
            volImg.vol = zeros(size(volImg.vol));
            % mask the data so we only have meaningful voxels
            mniVox = allVox(logical(mniMask));
            % sort the data
            [voxVals, voxID] = sort(mniVox,'descend');
            % found how many voxels are in the top n%
            nVox = round(length(voxVals)*n/100);
            % save some stuff 
            allVoxVals{iSubj} = voxVals(1:nVox);
            maxVoxVal(iSubj) = max(voxVals(1:nVox));
            minVoxVal(iSubj) = min(voxVals(1:nVox));
            % create a logical vector indicating which voxels are in the
            % top n%
            topVox = zeros(size(mniVox));
            topVox(voxID(1:nVox)) = 1;
            % "unmask" the topVox vector 
            topVoxVec = zeros(size(allVox));
            topVoxVec(logical(mniMask)) = topVox;
            % reshape topVoxVec to get it back into volume format
            topVol = reshape(topVoxVec,size(volImg.vol));
            % put the data back into the image 
            volImg.vol = topVol;
            % save the image with the new information
            newFN = [topDir filesep 'sc-' con '-' subj '-top' num2str(n) 'percent.nii.gz'];
            MRIwrite(volImg,newFN);
        end
    end
end


%%%%%%%%%%%%%%%%% compute overlap (sum & proportion) %%%%%%%%%%%%%%%%%

for iSplit = 1:length(splits)
    topNdir = [overlapDir filesep splits{iSplit} filesep 'top' num2str(n)];
    hDir = [topNdir filesep 'subCtx'];
    sumImg = [topNdir filesep 'sc-allSubjs-' con '-top' num2str(n) 'percent-MNI_sum.nii.gz'];
    propImg = [topNdir filesep 'sc-allSubjs-' con '-top' num2str(n) 'percent-MNI_prop.nii.gz'];
    imgs = dir([hDir filesep 'sc*top' num2str(n) 'percent.nii.gz']);
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








