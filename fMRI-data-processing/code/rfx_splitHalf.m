function permCMD = rfx_splitHalf()
permCMD = {};
startDir = '/PATH/TO/faces';
splits = {'oddRuns' 'evenRuns'};
hemis = {'lh' 'rh'};
con = 'FvO';
% for each half of data
for iSplit = 1:length(splits)
    splitDir = [startDir filesep 'rfx_sm4' filesep splits{iSplit}];
    % for each hemisphere
    for iHemi = 1:2
        hemi = hemis{iHemi};
        hemiDir = [splitDir filesep hemi];
        % run the rfx
        cmd = runRFX(hemiDir,hemi,5000,2,con);
        permCMD{end+1} = cmd;
    end
end