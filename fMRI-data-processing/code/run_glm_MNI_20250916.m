% run_gss_fROI
% 2024.06.25
% hlk
% updaed for volume fROI analysis
% 2025.09.16
% hlk
clear all
close all
clc

startDir = '/PATH/TO/faces';

% wrapping through each experiment
grps = {'deen2015' 'EvLab' 'isik2017' 'skerry2014'};
strs = {'SAX_' 'sub' 'KAN_' 'SAX_'};

exps = {{'bio' 'mega' 'tom' 'tva'} {'gesture' 'lang2cond'} {'plw' 'shape' 'tom'} ...
    {'eib1' 'tom'}};

condNames = {{{'BioMot' 'BioScram' 'Coh' 'Static' 'Sfm' 'SfmScram'} ... % bio
    {'ToM' 'Bio' 'PMo' 'PNM' 'Jab' 'Mus'} {'FB' 'FP'} {'Vocal' 'nonvocal'}} ...
    {{'GNA' 'GA' 'NGNA' 'NGA' 'A'} {'SENT' 'NONS'}} ...
    {{'plwInt' 'plwNoInt'} {'help' 'hinder' 'noInteraction' 'physics'} {'FB' 'FP' 'fbQ' 'fpQ'}} ...
    {{'mu' 'fu' 'mh' 'fh' 'nu' 'su' 'nh' 'sh'} {'FB' 'FP' 'fbQ' 'fpQ'}}};
condNums = {{1:6 1:6 1:2 1:2} {1:5 1:2} {1:2 1:4 1:4} {1:8 1:4}};
runLists = {{'bioRuns' 'megaRuns' 'tomRuns' 'tvaRuns'} {'gestRuns' 'lang-loc-rlf.txt'} ...
    {'plwRuns' 'shapeRuns' 'tomRuns'} {'eib1Runs' 'tomRuns'}};
subjLists = {{'bioSubjs' 'megaSubjs' 'tomSubjs' 'tvaSubjs'} {'gestSubjs' 'langSubjs'} ...
    {'plwSubjs' 'shapeSubjs' 'tomSubjs'} {'eib1Subjs' 'tomSubjs'}};
durs = {[20.25 9 14 16] [21 36] [16 12 10] [3 10]};
paras = {{'bio.para' 'mega.para' 'tom.para' 'tva.para'} {'gest.para' 'lang2cond.para'} ...
    {'plw.para' 'shape.para' 'tom.para'} {'eib1.para' 'tom.para'}};
cons = {{{} {} {'FBvFP'} {}} {{} {'SENTvNONS'}} {{'IvN'} ...
    {'HELPvHIND' 'INTvNI' 'SOCvOBJ' 'SOCvNONSOC'} {'FBvFP'}} ...
    {{'POSvNEG' 'SOCvAGT' 'SOCPOSvSOcNEG' 'AGTPOSvAGTNEG'} {'FBvFP'}}};
tops = {{{} {} {'1'} {}} ...
    {{} {'1'}}         ...
    {{'1'} {'1' {'1' '2'} {'1' '2'} {'1' '2'}} {'1' '3'}}    ...
    {{{'3' '4' '7' '8'} {'6' '8'} '8' '7'} {'1' '3'}}};
bots = {{{} {} {'2'}     {}} ...
    {{} {'2'}}         ...
    {{'2'} {'2' '3' '4' {'3' '4'}} {'2' '4'}}     ...
    {{{'1' '2' '5' '6'} {'5' '7'} '6' '5'} {'2' '4'}}};


for iGrp = 2%1:length(grps)
    grpDir = [startDir filesep grps{iGrp}];
    % now set the analysis for each experiment
    for iExp = 1%1:length(exps{iGrp})
        % get the information for this particular experiment
        exp = exps{iGrp}{iExp};
        para = paras{iGrp}{iExp};
        nCond = num2str(length(condNums{iGrp}{iExp}));
        dur = num2str(durs{iGrp}(iExp));
        rList = runLists{iGrp}{iExp};
        % cd to the correct directory
        analysisDir = [grpDir filesep exp filesep 'analysis']; 
        cd(analysisDir);
        % if the analysis directory already exists, we need to remove it so
        % we can re-write it and make sure it has the correct parameters
        ana = [exp '-mni305-2mm-sm4'];
        anaDir = [analysisDir filesep ana]
        exist(anaDir,'dir')
%         if exist(anaDir,'dir'); continue; end
        % okay, now we can set the analysis
        cmd1 = ['mkanalysis-sess -a ' ana ' -mni305 2 -fsd bold -fwhm 4 -tpexclude exTPs.txt ' ...
            '-event-related -per-run -paradigm ' para ' -nconditions ' nCond ...
            ' -refeventdur ' dur ' -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ' rList];
%         system(cmd1);
        
        % check for contrasts & add them to the analysis, if needed
        con = cons{iGrp}{iExp};
        subjList = subjLists{iGrp}{iExp};
        if ~isempty(con)
            for iCon = 1:length(con)
                cmd2 = ['mkcontrast-sess -analysis ' ana ' -contrast ' con{iCon}];
                top = tops{iGrp}{iExp}{iCon};
                bot = bots{iGrp}{iExp}{iCon};
                if length(top) > 1
                    for iTop = 1:length(top)
                        cmd2 = [cmd2 ' -a ' top{iTop}];
                    end
                else
                    cmd2 = [cmd2 ' -a ' top];
                end
                if length(bot) > 1
                    for iBot = 1:length(bot)
                        cmd2 = [cmd2 ' -c ' bot{iBot}];
                    end
                else
                    cmd2 = [cmd2 ' -c ' bot];
                end
%                 system(cmd2);
            end
            % now create the command to actualy run the analysis
            cmd3 = ['selxavg3-sess -sf ' subjList ' -df sessdir -analysis ' ana ' -overwrite'];
        else
            % if there are no contrasts, need to indicate that
            cmd3 = ['selxavg3-sess -sf ' subjList ' -df sessdir -analysis ' ana ' -no-con-ok -overwrite'];
        end
        disp(cmd3)
%         system(cmd3)
    end
end

