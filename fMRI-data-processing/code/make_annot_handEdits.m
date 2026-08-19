function make_annot_handEdits()
% '/PATH/TO/faces/overlap_sm4/oddRuns/top10/clusterSummaries/lh/lbls_thr45percent'
ctab = '/PATH/TO/faces/code/annot_color_lookup_table.txt';
clustDir = '/PATH/TO/faces/overlap_sm4/oddRuns/top10/clusterSummaries';
hemis = {'lh' 'rh'};
for iHemi = 1:length(hemis)
    h = hemis{iHemi};
    oldLblDir = [clustDir filesep h filesep 'lbls_thr45percent'];
    newLblDir = [clustDir filesep h filesep 'lbls_thr45percent_chgNames'];
    mkdir(newLblDir)
    lbls = dir([oldLblDir filesep '*.label']); lbls = {lbls.name};
    for iLbl = 1:length(lbls)
        if iLbl < 10 
            n = ['00' num2str(iLbl)];
        else
            n = ['0' num2str(iLbl)];
        end
        oldLbl = [oldLblDir filesep lbls{iLbl}];
        newLbl = [newLblDir filesep h '-' n '.label'];
        system(['cp ' oldLbl ' ' newLbl]);
    end
    clear('lbls');
    cd(newLblDir);
    lbls = dir([newLblDir filesep '*.label']); lbls = {lbls.name};
    cmd = ['mris_label2annot --s fsaverage --h ' h ' --surf inflated --ctab ' ctab];
    for iLabel = 1:length(lbls)
        cmd = [cmd ' --l ' lbls{iLabel}];
    end
    aFN = 'FvO_overlap_top10_thr45percent_handEdits';
    cmd = [cmd ' --a ' aFN]
    system(cmd);
end