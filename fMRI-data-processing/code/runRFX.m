function cmd = runRFX(workDir,surf,nPerm,pThr,con)

imgDir = [workDir filesep 'conImgs'];

% concatenate images
if strcmp(surf,'lh')
    concImg = [workDir filesep 'lh-' con '-ces-fsaverage.nii.gz'];
    c = [imgDir filesep 'lh-' con '*-ces.nii.gz'];
elseif strcmp(surf,'rh')  
    concImg = [workDir filesep 'rh-' con '-ces-fsaverage.nii.gz'];
    c = [imgDir filesep 'rh-' con '*-ces.nii.gz'];
else
    concImg = [workDir filesep con '-vol-ces-mni2mm.nii.gz'];
    c = [imgDir filesep 'mni2mm-' con '*-ces.nii.gz'];
end
system(['mri_concat --o ' concImg ' --i ' c]);

% group RFX
if strcmp(surf,'lh')
    system(['mri_glmfit --y ' concImg ' --osgm --no-prune --surf fsaverage lh --glmdir ' workDir '/ --nii.gz']);
elseif strcmp(surf,'rh')
    system(['mri_glmfit --y ' concImg ' --osgm --no-prune --surf fsaverage rh --glmdir ' workDir '/ --nii.gz']);
else
    system(['mri_glmfit --y ' concImg ' --osgm --no-prune --glmdir ' workDir '/ --nii.gz']);
end

% permutation text
% system(['mri_glmfit-sim --glmdir ' workDir ' --cwp .05 --perm ' nPerm ' ' pThr ' abs --3spaces --overwrite --y ' concImg]);
disp('RUN in TERMINAL')
cmd = ['mri_glmfit-sim --glmdir ' workDir ' --cwp .05 --3spaces --overwrite --y ' concImg ' --perm ' nPerm ' ' pThr ' abs'];
disp(cmd);
