function make_annot_file(topN)

% mris_label2annot --s fsaverage --h rh --a FvO-z1pt3-thr30subjs --surf inflated --ldir ./thr30subjs/ --ctab /PATH/TO/faces/code/annot_color_lookup_table.txt 

ctab = '/PATH/TO/faces/code/annot_color_lookup_table.txt';

oddDir = '/PATH/TO/faces/overlap_sm4/oddRuns';
anaDir = [oddDir filesep 'top' num2str(topN) filesep 'clusterSummaries'];

hemis = {'lh' 'rh'};

pTHRS = 0.1:0.05:0.95;

for i = 1:length(pTHRS)
    p = pTHRS(i);
    dDir = ['top' num2str(topN)];
    sDir = ['thr' num2str(p*100) 'percent'];
    for iHemi = 1:length(hemis)
        h = hemis{iHemi};
        hemiDir = [anaDir filesep h];
        lblDir = [hemiDir filesep sDir];
        cd(lblDir)
        lbls = dir([lblDir filesep '*.label']); lbls = {lbls.name};
        cmd = ['mris_label2annot --s fsaverage --h ' h ' --surf inflated --ctab ' ctab];
        for iLabel = 1:length(lbls)
            cmd = [cmd ' --l ' lbls{iLabel}];
        end
        aFN = ['FvO_overlap_' dDir '_' sDir];
        cmd = [cmd ' --a ' aFN]
        system(cmd);
    end
end


