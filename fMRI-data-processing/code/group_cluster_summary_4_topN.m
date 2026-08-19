function group_cluster_summary_4_topN(n)
startDir = '/PATH/TO/faces/overlap_sm4/oddRuns/';
anaDir = [startDir filesep 'top' num2str(n)];
hemis = {'lh' 'rh'};
for iHemi = 1:length(hemis)
    h = hemis{iHemi};
    propFN = [anaDir filesep h '-allSubjs-FvO-top' num2str(n) 'percent-fsaverage_prop.nii.gz'];
    saveDir = [anaDir filesep 'clusterSummaries'];
    hemiDir = [saveDir filesep h];
    if ~exist(saveDir,'dir'); mkdir(saveDir); end
    if ~exist(hemiDir,'dir'); mkdir(hemiDir); end
    % percentage of subjects that have part of a cluster in this vertex
    pTHRS = 0.1:0.05:0.95;
    for p = 1:length(pTHRS)
        pthr = pTHRS(p);
        summFN = [hemiDir filesep h '-FvO-thr' num2str(pthr*100) 'percent-clusterSummary'];
        outFN =  [hemiDir filesep h '-FvO-thr' num2str(pthr*100) 'percent-clusterSummary.nii.gz'];
        outlabelbase = [hemiDir filesep 'thr' num2str(pthr*100) 'percent' filesep];
        mkdir(outlabelbase);
        cmd = ['mri_surfcluster --in ' propFN ' --thmin ' num2str(pthr) ' --sign pos --subject fsaverage --hemi ' h ' --sum ' summFN ' --o ' outFN ' --surf inflated --minarea 10 --olab ' outlabelbase h];
        system(cmd);
    end
end
