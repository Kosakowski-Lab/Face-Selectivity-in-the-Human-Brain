function make_vol_rois(topN,thr)

clusterDir = ['/PATH/TO/faces/overlap_sm4/oddRuns/top' ...
    num2str(topN) '/clusterSummaries/sc/thr' num2str(thr) 'percent'];
saveDir = [clusterDir filesep 'ROIs_noEdits'];
nameDir = [clusterDir filesep 'ROIs_aseg'];
mkdir(saveDir);
mkdir(nameDir)
clusterImg = [clusterDir filesep 'sc-FvO-thr' num2str(thr) 'percent-clusterNumber.nii.gz'];
c = MRIread(clusterImg);
n = max(unique(unique(unique(c.vol))));
mniDir = '/PATH/TO/brains/subjAnats/MNI152_FS/mri';

for iClust = 1:n
    if sum(sum(sum(c.vol==iClust))) > 10
        if iClust < 10
            str = ['00' num2str(iClust)];
        elseif iClust < 100
            str = ['0' num2str(iClust)];
        else
            str = num2str(iClust);
        end
        saveFN = [saveDir filesep 'sc-' str '.nii.gz'];
        cmd = ['fslmaths ' clusterImg ' -thr ' num2str(iClust) ' -uthr ' num2str(iClust) ' -bin ' saveFN];
        system(cmd);
    end
end

