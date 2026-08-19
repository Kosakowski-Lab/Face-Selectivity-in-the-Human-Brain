clear all
close all
clc

% Ev used a smoothing kernel of 4 mm so going to update dyloc analyses accordingly

% we want to do several analyses:
% brain partitions
% left hemisphere
% right hemisphere
% volume (for subcortical)
% data partitions
% all runs (for RFX)
% each run (for fROI & RSA)
% all runs but one (for fROI & RSA)
% I want to use impulse nuisance regressors (>0.5 mm)
% FN --> exTPs.txt
% flag --> -tpexclude

startDir = '/PATH/TO/faces';

grps = {'EvLab' 'cohen2019_5cond' 'cohen2019_6cond' 'cohen2019_kids' ...
    'deen2015' 'isik2017_2cond' 'isik2017_5cond' 'skerry2014'};
blockDurs = [9 18 18 18 18 18 18 22];
nConds = [5 5 6 5 3 2 5 6];
para = 'dyLoc.para';
hemis = {'rh' 'lh'};
subjList = 'dylocSplitHalf';


for iGrp = 1:length(grps)
    if iGrp == length(grps)
        skerry = true;
    else
        skerry = false;
    end
    c = num2str(nConds(iGrp));
    d = num2str(blockDurs(iGrp));
    anaDir = [startDir filesep grps{iGrp} filesep 'dyLoc' filesep 'analysis'];
    cd(anaDir);
    % make sure we do this for each split (split half)
    for iSplit = 1:2
        if iSplit == 1
            rList = 'dylocOdd';
            sp = 'oddRuns';
        else
            rList = 'dylocEven';
            sp = 'evenRuns';
        end
        % we need to do each hemishpere of the surface
        % need fsavearge and subject-specific for each data split
        for iHemi = 1:2
            h = hemis{iHemi};
            %%%%% fsaverage surface %%%%%
            aName = ['dyloc-fsSurf-' h '-sm4-' sp];
            if exist(aName,'dir'); system(['rm -rf ' aName]); end
            cmd1 = ['mkanalysis-sess -a ' aName ' -surface fsaverage ' h ...
                ' -fsd bold -fwhm 4 -event-related -per-run -paradigm ' ...
                para ' -nconditions ' c ' -refeventdur ' d ' -tpexclude exTPs.txt' ...
                ' -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ' rList];
            cmd3 = ['selxavg3-sess -sf ' subjList ' -df sessdir -analysis ' aName ' -overwrite'];
            system(cmd1);
            makeContrasts(aName,str2num(c),skerry);
            system(cmd3);
            %%%%% subject-specific surface %%%%%
            aName = ['dyloc-surfSelf-' h '-sm4-' sp];
            if exist(aName,'dir'); system(['rm -rf ' aName]); end
            cmd1 = ['mkanalysis-sess -a ' aName ' -surface self ' h ...
                ' -fsd bold -fwhm 4 -event-related -per-run -paradigm ' ...
                para ' -nconditions ' c ' -refeventdur ' d ' -tpexclude exTPs.txt' ...
                ' -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ' rList];
            cmd3 = ['selxavg3-sess -sf ' subjList ' -df sessdir -analysis ' aName ' -overwrite'];
            system(cmd1);
            makeContrasts(aName,str2num(c),skerry);
            system(cmd3);
        end
    end
end


function makeContrasts(aName,nConds,skerry)
if (nConds == 5 || (nConds==6)) && ~skerry
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast FvO -a 1 -c 4'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast FvBSOSc -a 1 -c 4 -c 2 -c 3 -c 5'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast SvO -a 3 -c 4'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast SvFBOSc -a 3 -c 4 -c 2 -c 1 -c 5'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast SvSc -a 3 -c 5'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast BvO -a 2 -c 4'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast BvFSOSc -a 2 -c 4 -c 3 -c 1 -c 5'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast BvSc -a 2 -c 5'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast OvFBSSc -a 4 -c 2 -c 3 -c 1 -c 5'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast OvSc -a 4 -c 5'];
    system(cmd2);
elseif nConds == 2
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast FvO -a 1 -c 2'];
    system(cmd2);
elseif skerry
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast FvO -a 5 -c 6'];
    system(cmd2);
elseif nConds == 3
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast FvO -a 1 -c 3'];
    system(cmd2);
    cmd2 = ['mkcontrast-sess -analysis ' aName ' -contrast BvO -a 2 -c 3'];
    system(cmd2);
end
end