function [allSubjs, allParcs, meanIndBetas, meanNIbetas] = gss_fROI_volume(subj, selectDir, extractDir, parcVecs, parcNames, nPer, conds, conName, co)
% selectDir is the subject-specific analysis directory to select voxels
% extractDir is the subject-specific analysis directory to extract betas
% lblFN is the full filename for the subject-specifc label file to be used in fROI analysis
% nPer it the top perentage of vertices in the label file to select
% nConds is the number of conditions in the extract paradigm
% conName is the contrast to use for selectiving voxels
% hlk
% 2024.06.27
% updated to use with the volume data rather than surface data
% hlk
% 2025.09.13
% updated to use with volume data in MNI space
% 2025.10.10
% hlk

% contrast map to select voxels
conPath = [selectDir filesep conName];
conFN = [conPath filesep 'ces.nii.gz'];
con = MRIread(conFN);
conVec = reshape(con.vol,[numel(con.vol) 1]);
clear('conPath','conFN','con');

% non-independent betas for sanity check
betaFN = [selectDir filesep 'beta.nii.gz'];
beta = MRIread(betaFN);
dims = size(beta.vol);
niBetaMat = reshape(beta.vol,[prod(dims(1:3)) dims(4)]);
clear('betaFN','beta','dims');

% independent betas
betaFN = [extractDir filesep 'beta.nii.gz'];
beta = MRIread(betaFN);
dims = size(beta.vol);
indBetaMat = reshape(beta.vol,[prod(dims(1:3)) dims(4)]);
clear('betaFN','beta','dims');

% here we go.... 
for iROI = 1:length(parcNames)
    allSubjs{iROI} = subj;
    allParcs{iROI} = parcNames{iROI};
    meanIndBetas(iROI,1:5) = nan; % make sure if there's nothing there, it's a nan
    meanNIbetas(iROI,1:5) = nan;
    
    % find the values for this ROI
    [niBetas, indBetas] = findTop(parcVecs(iROI,:), conVec, nPer, niBetaMat, indBetaMat, conds);
    meanIndBetas(iROI,co) = indBetas;
    meanNIbetas(iROI,co) = niBetas;
    clear('mb');
end

function [niBetas, indBetas] = findTop(parcVec, conVec, nPer, niBetaMat, indBetaMat, conds)

[conSort, idx] = sort(conVec(logical(parcVec)),'descend');
n = round(length(conSort)*nPer/100);
topVox = zeros(size(conSort));
topVox(idx(1:n)) = 1;

% get a topNvox vector
topNvox = zeros(size(conVec));
topNvox(logical(parcVec)) = topVox;

% mean non-independent contrast value (for troubleshooting)
niCon = mean(conSort(1:n),'omitnan');

% non-independent betas
topNiBetas = niBetaMat(logical(topNvox),conds);
niBetas = mean(topNiBetas,'omitnan');

% independent betas
topIndBetas = indBetaMat(logical(topNvox),conds);
indBetas = mean(topIndBetas,'omitnan');
