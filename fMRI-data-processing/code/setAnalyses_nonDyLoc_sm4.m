clear all
close all
clc

% shape lh & rh sm4 missing
% lang all sm4 missing
% eib1 all sm4 missing
% skerry tom lh & rh sm4 missing

runInTerm = {};

studies = {'deen2015' 'isik2017' 'skerry2014' 'EvLab'};
subjStr = {'SAX*' 'KAN*' 'SAX*' 'sub*'};
exps = {{'bio' 'mega' 'tom' 'tva'} ... % deen2015
    {'plw' 'shape' 'tom'} ... % isik2017
    {'eib1' 'eib2' 'tom'} ... % skerry2014
    {'gesture' 'lang'}}; % EvLab
paras = {{'bio.para' 'mega.para' 'tom.para' 'tva.para'} ...
    {'plw.para' 'shape.para' 'tom.para'} ...
    {'eib1.para' 'eib2.para' 'tom.para'} ...
    {'gest.para' 'langloc.par'}};
runLists = {{'bioRuns' 'megaRuns' 'tomRuns' 'tvaRuns'} ...
    {'plwRuns' 'shapeRuns' 'tomRuns'} ...
    {'eib1Runs' 'eib2Runs' 'tomRuns'} ...
    {'gestRuns' 'lang-loc-rlf.txt'}};
subjLists = {{'bioSubjs' 'megaSubjs' 'tomSubjs' 'tvaSubjs'} ...
    {'plwSubjs' 'shapeSubjs' 'tomSubjs'} ...
    {'eib1Subjs' 'eib2Subjs' 'tomSubjs'} ...
    {'gestSubjs' 'langSubjs'}};
blockDurs = {[20.25 9 2 2] [16 12 12] [3 3 12] [10.5 18]};
nConds = {[6 6 14 16] [2 4 4] [8 4 4] [5 2]};
hemis = {'rh' 'lh'};

startDir = '/PATH/TO/faces';

% all betas for native volume and surface
for iStudy = 1:length(studies)
    for iExp = 1:length(exps{iStudy})
        % get all of the relevant variables for this analysis
        e = exps{iStudy}{iExp};
        c = num2str(nConds{iStudy}(iExp));
        d = num2str(blockDurs{iStudy}(iExp));
        rList = runLists{iStudy}{iExp};
        para = paras{iStudy}{iExp};
        sList = subjLists{iStudy}{iExp};
        
        % get to the analysis directory
        anaDir = [startDir filesep studies{iStudy} filesep e filesep 'analysis'];
        cd(anaDir);
        
        % analyses in the volume for fROI (native)
        aName = [e '-native-sm4'];
        cmd1 = ['mkanalysis-sess -a ' aName ' -native ' ...
            '-fsd bold -fwhm 4 -event-related -paradigm ' ...
            para ' -nconditions ' c ' -refeventdur ' d ' -tpexclude exTPs.txt' ...
            ' -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ' rList];
        cmd2 = ['selxavg3-sess -sf ' sList ' -df sessdir -analysis ' ...
            aName ' -overwrite -no-con-ok'];
        system(cmd1);
        % system(cmd2);
        runInTerm{end+1} = cmd2;
        
        % analysis for fROI on the surface (subject-specific)
        for iHemi = 1:2
            h = hemis{iHemi};
            aName = [e '-surfSelf-' h '-sm4'];
            cmd1 = ['mkanalysis-sess -a ' aName ' -surface self ' h ...
                ' -fsd bold -fwhm 4 -event-related -per-run -paradigm ' ...
                para ' -nconditions ' c ' -refeventdur ' d ' -tpexclude exTPs.txt' ...
                ' -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ' rList];
            cmd2 = ['selxavg3-sess -sf ' sList ' -df sessdir -analysis ' ...
                aName ' -overwrite -no-con-ok'];
            system(cmd1);
            % system(cmd2);
            runInTerm{end+1} = cmd2;
        end
    end
end
            