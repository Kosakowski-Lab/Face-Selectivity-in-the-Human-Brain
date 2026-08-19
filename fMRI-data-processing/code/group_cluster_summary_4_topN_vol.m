function group_cluster_summary_4_topN_vol(n)
startDir = '/PATH/TO/faces/overlap_sm4/oddRuns/';
anaDir = [startDir filesep 'top' num2str(n)];

h = 'sc';
propFN = [anaDir filesep h '-allSubjs-FvO-top' num2str(n) 'percent-MNI_prop.nii.gz'];
saveDir = [anaDir filesep 'clusterSummaries'];
hemiDir = [saveDir filesep h];
if ~exist(saveDir,'dir'); mkdir(saveDir); end
if ~exist(hemiDir,'dir'); mkdir(hemiDir); end
% percentage of subjects that have part of a cluster in this vertex
pTHRS = 0.1:0.05:0.9;
for p = 1:length(pTHRS)
    pthr = pTHRS(p);
    outlabelbase = [hemiDir filesep 'thr' num2str(pthr*100) 'percent' filesep];
    mkdir(outlabelbase);
    summFN = [outlabelbase filesep h '-FvO-thr' num2str(pthr*100) 'percent-clusterSummary'];
    outFN = [outlabelbase filesep h '-FvO-thr' num2str(pthr*100) 'percent-clusterOut.nii.gz'];
    numFN = [outlabelbase filesep h '-FvO-thr' num2str(pthr*100) 'percent-clusterNumber.nii.gz'];
    cmd = ['mri_volcluster --in ' propFN ' --thmin ' num2str(pthr) ' --sign pos --no-adjust --fsaverage --sum ' summFN ' --out ' outFN ' --minsize 10 --ocn ' numFN ];
    system(cmd);
end
end
