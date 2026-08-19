clear all
close all
clc

mniDir = '/PATH/TO/brains/subjAnats/MNI152_FS/mri';
save1dir = [mniDir filesep 'mni-aseg-parcs'];
save2dir = [mniDir filesep 'mni-2mm-aseg-parcs'];
img = [mniDir filesep 'aparc+aseg.nii.gz'];
mni2mm = [mniDir filesep 'mni305-2mm-brain.nii.gz'];
fsLUT = '/PATH/TO/FreeSurferColorLUT_edits.txt';
fid = fopen(fsLUT);
lutCell = textscan(fid,'%u %s %s %s %s %s');
fclose(fid);
m = MRIread(img);
lbls = unique(unique(unique(m.vol)));
for i = 2:length(lbls)
    idx = find([lutCell{1}] == i);
    str = ['lut' num2str(i) '_lbl_' lutCell{2}{idx}];
    roiFN = [save1dir filesep 'mni-1mm_' str '.nii.gz'];
    roi2mmFN = [save2dir filesep 'mni-2mm_' str '.nii.gz'];
    cmd = ['fslmaths ' img ' -thr ' num2str(i) ' -uthr ' num2str(i) ' ' roiFN];
    system(cmd);
    cmd = ['mri_convert -i ' roiFN ' -rl ' mni2mm ' -o ' roi2mmFN];
    system(cmd);
    cmd = ['fslmaths ' roi2mmFN ' -bin -mul ' num2str(i) ' ' roi2mmFN];
    system(cmd);
end