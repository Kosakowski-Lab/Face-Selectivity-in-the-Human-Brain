function betas = gss_fROI_allExps_volume(grpDir, subj, selectDir, exps, parcVecs, parcNames, nPer, conName, conds)
% selectDir is the subject-specific analysis directory to select voxels
% extractDir is the subject-specific analysis directory to extract betas
% lblFN is the full filename for the subject-specifc label file to be used in fROI analysis
% nPer it the top perentage of vertices in the label file to select
% nConds is the number of conditions in the extract paradigm
% conName is the contrast to use for selectiving voxels
% hlk
% 2024.06.30

% exps = {{'bio' 'mega' 'tom' 'tva'} {'gesture' 'lang2cond'} {'plw' 'shape' 'tom'} ...
%     {'eib1' 'tom'}};


% check if this subject has any of the experiment
incl = 0 ;
for iExp = 1:length(exps)
    exp = exps{iExp};
    if strncmp(grpDir(end-7:end),'isik2017',8) && iExp==3
        expDir = [grpDir '_2cond' filesep exp filesep subj filesep 'bold'];
        if ~exist(expDir,'dir')
            expDir = [grpDir '_2cond' filesep exp filesep subj filesep 'bold'];
        end
    else
        expDir = [grpDir filesep exp filesep subj filesep 'bold'];
    end
    extractDir = [expDir filesep exp '-mni305-2mm-sm4'];
    betas{iExp}(1:length(parcNames),conds{iExp}) = nan;
    if exist(extractDir,'dir')
        incl = incl + 1;
    end
end

% if this participant has any of the experiments, we run the subject
if incl ~= 0
    conPath = [selectDir filesep conName];
    conFN = [conPath filesep 'ces.nii.gz'];
    con = MRIread(conFN);
    conVec = reshape(con.vol,[numel(con.vol) 1]);
    
    % get the beta values from each experiment
    for iExp = 1:length(exps)
        exp = exps{iExp};
        ana = [exp '-mni305-2mm-sm4'];
        boldDir = [grpDir filesep exp filesep subj filesep 'bold'];
        extractDir = [boldDir filesep ana];
        if exist(extractDir,'dir')
            betaFN = [extractDir filesep 'beta.nii.gz'];
            beta = MRIread(betaFN);
            dims = size(beta.vol);
            betaMat = reshape(beta.vol,[prod(dims(1:3)) dims(4)]);
            % get the beta values for the top n% of voxels
            for iParc = 1:length(parcNames)
                topBetaMat = findTop(parcVecs(iParc,:), conVec, nPer, betaMat, conds{iExp});
                if ~all(topBetaMat==0)
                    betas{iExp}(iParc,conds{iExp}) = topBetaMat;
                end
                clear('topBetaMat')
            end
            clear('betaMat');
        end
    end
end


function betas = findTop(parcVec, conVec, nPer, betaMat, conds)

    [conSort, idx] = sort(conVec(logical(parcVec)),'descend');

    % some ROIs might not have voxels -- e.g., if the cerebellum was cut out of
    % the bounding box
    if all(conSort==0)
        betas = nan(1,length(conds));
    else
        % find the top voxels
        n = round(length(conSort)*nPer/100);
        topVox = zeros(size(conSort));
        topVox(idx(1:n)) = 1;

        % get a topNvox vector
        topNvox = zeros(size(conVec));
        topNvox(logical(parcVec)) = topVox;

        % betas
        topBetas = betaMat(logical(topNvox),conds);
        betas = mean(topBetas,'omitnan');
    end
end
end