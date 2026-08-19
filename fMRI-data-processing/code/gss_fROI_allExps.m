function betas = gss_fROI_allExps(grpDir, subj, hemi, selectDir, exps, lblFN, nPer, conName, conds)
% selectDir is the subject-specific analysis directory to select voxels
% extractDir is the subject-specific analysis directory to extract betas
% lblFN is the full filename for the subject-specifc label file to be used in fROI analysis
% nPer it the top perentage of vertices in the label file to select
% nConds is the number of conditions in the extract paradigm
% conName is the contrast to use for selectiving voxels
% hlk
% 2024.06.30

% deen dyloc #1
% 'dylocSubjs-surfSelf-lh-sm4'
% 'dylocSubjs-surfSelf-rh-sm4'

% isik 2 cond dyloc #3
% 'dylocSubjs-surfSelf-rh-sm4'
% 'dylocSubjs-surfSelf-lh-sm4'

% isik 5 cond dyloc #3
% 'dylocSubjs-surfSelf-lh-sm4'
% 'dylocSubjs-surfSelf-lh-sm4'

% skerry dyloc #2
% 'dylocSubjs-surfSelf-lh-sm4'
% 'dylocSubjs-surfSelf-lh-sm4'


% % check if this subject has any of the experiment
% incl = 0 ;
% for iExp = 1:length(exps)
%         expDir = [grpDir filesep exps{iExp} filesep subj filesep 'bold'];
%     extractDir = [expDir filesep exps{iExp} '-surfSelf-' hemi '-sm4'];
%     betas{iExp}(conds{iExp}) = nan;
%     if exist(extractDir,'dir')
%         incl = incl + 1;
%     end
% end
% 
% if incl ~= 0

conPath = [selectDir filesep conName];

conFN = [conPath filesep 'ces.nii.gz'];
lbl = read_label_customFN(lblFN);
if ~isempty(lbl)
lbl(lbl(:,1)==0,:) = [];
con = MRIread(conFN);
conVec = con.vol(lbl(:,1));
[conSort, idx] = sort(conVec,'descend');
n = round(length(conSort)*nPer/100);
topvert = zeros(size(conVec));
topvert(idx(1:n)) = 1;

% get a topNvert vector
topNvert = zeros(size(con.vol));
topNvert(lbl(:,1)) = topvert;

% mean non-independent contrast value
niCon1 = mean(conSort(1:n),'omitnan');
niCon2 = mean(con.vol(logical(topNvert)),'omitnan');

% get the beta values from each experiment
for iExp = 1:length(exps)
    if iExp == 1
        if strcmp(selectDir(end-2:end),'Odd')
            extractDir = [selectDir(1:end-3) 'Even'];
        elseif strcmp(selectDir(end-6:end),'oddRuns')
            extractDir = [selectDir(1:end-7) 'evenRuns'];
        else
            extractDir = [];
        end
    else
        expDir = [grpDir filesep exps{iExp} filesep subj filesep 'bold'];
        if strcmp(exps{iExp},'gesture')
            extractDir = [expDir filesep 'gest-surfSelf-' hemi '-sm4'];
        else
            extractDir = [expDir filesep exps{iExp} '-surfSelf-' hemi '-sm4'];
        end
    end
    if ~exist(extractDir,'dir')
        betas{iExp}(conds{iExp}) = nan;
    else
        betaFN = [extractDir filesep 'beta.nii.gz'];
        beta = MRIread(betaFN);
        betaMat = squeeze(beta.vol(1,logical(topNvert),1,conds{iExp}));
        betas{iExp}(conds{iExp}) = mean(betaMat,'omitnan');
    end
end
end
end

