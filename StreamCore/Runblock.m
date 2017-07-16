function [FullUserdata carryover]= Runblock(Parameters,FullUserdata, blocktype,blocknum,carryover)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Runblock(Parameters,Userdata.blocktype,blocknum,carryover)
% Runblock executes a single block of trials.
%
% Input
%    Parameters: Parameter set for this experiment (Setparameters)
%    Userdata:  Data for the current subject
%    blocktype:  name of the current block
%    blocknum:  Which block type is this?
%    carryover: variables saved from previous blocks that will be needed later
%
%RunBlock.m calls the following Stream functions:
%	Showstream
%	Preparescreen
%	WriteDataFiles
%	ShowError
%	Streamcleanup
%	CheckTrials
%
%RunBlock.m is called by:
%   Runexp


Block_Export.dummy = 0;
Trial_Export.dummy = 0;


timestamp_variables = fix(clock);
Parameters.Timestamp = sprintf('Date: %d/%d/%d Time %d:%d:%d', timestamp_variables(1,2),timestamp_variables(1,3),timestamp_variables(1,1),timestamp_variables(1,4),timestamp_variables(1,5),timestamp_variables(1,6));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setup the events within this block
try
    crash
catch
    err = lasterror;
end


try
    modeflag ='InitializeBlock';
    
    evalstring=sprintf('%s(Parameters,[],0,blocknum,modeflag,[],Block_Export,Trial_Export,FullUserdata.Demodata)',blocktype{1}); %sets up the stimuli and initializes other parameters

    [x2 Parameters Stimuli_sets Block_Export Trial_Export Numtrials] = eval(evalstring);
    
    FullUserdata.Blocks(blocknum).Stimuli = Stimuli_sets;
    FullUserdata.Blocks(blocknum).Parameters = Parameters;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Loop through all of the trials within a block (InitializeTrial)
    trial = 0;
    carryover.endblock = 0;
    
    while(trial < Numtrials)
        clear Trial_Export;
        Trial_Export.dummy = 0;
        
        trial =  trial + 1;
        
        if(Parameters.trialrestart)
            Parameters = Preparescreen(Parameters);    %initialize the PTB screen
        end
        
        
        %figure out the datafile prefix for screenshots saved during this trial
        s_num = FullUserdata.Demodata.s_num;
        fileprefix =sprintf('Sub%sBlock%dtrial%d',s_num,blocknum,trial);
        
        
        modeflag = 'InitializeTrial';
        evalstring=sprintf('%s(Parameters,Stimuli_sets,trial,blocknum,modeflag,[],Block_Export,Trial_Export,FullUserdata.Demodata)',blocktype{1}); %sets up the stimuli and initializes other parameters
        [PreEvents Parameters tempstim Block_Export Trial_Export ] = eval(evalstring);
        
        
        %Check the trial's event to make sure they will not crash
        CheckTrials(PreEvents,Stimuli_sets);
        
        
        %Show the actual sequence of events on screen
        %save the output in Events which stores all of the temporal information
        Events = Showstream(Parameters, PreEvents,tempstim,fileprefix);
        
        
        if isstruct(carryover) == 1
            carryover.Events = Events;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %EndTrial
        
        modeflag = 'EndTrial';
        evalstring=sprintf('%s(Parameters,tempstim,trial,blocknum,modeflag,Events,Block_Export,Trial_Export,FullUserdata.Demodata)',blocktype{1}); %sets up the stimuli and initializes other parameters
        [x2 Parameters x5 Block_Export Trial_Export ]= eval(evalstring);
        
        for(i = 2:length(Events.time))   %what were the relative SOAs of each subsequent event?
            Events.timingdelta(i) = Events.timeflipped(i) -Events.timeflipped(i-1);
        end
        %Save trial information to the data file
        if isfield(Block_Export, 'dummy')
            Block_Export = rmfield(Block_Export, 'dummy');
        end
        if isfield(Trial_Export, 'dummy')
            Trial_Export = rmfield(Trial_Export, 'dummy');
        end
        
        FullUserdata.Blocks(blocknum).Trials(trial).Events = Events;
        FullUserdata.Blocks(blocknum).Trials(trial).Trial_Export =Trial_Export;
        FullUserdata.Blocks(blocknum).Block_Export =Block_Export;
        
        %Save back up data file every Parameters.saveevery trials
        if(trial/Parameters.saveevery) == ceil(trial/Parameters.saveevery);
            fname = sprintf('%s%s%s_backup',Parameters.datadir,Parameters.datafilename,FullUserdata.Demodata.s_num);
            save(fname,'FullUserdata');
         %   WriteDataFiles(FullUserdata);
            
        end
        
        if(Parameters.trialrestart);
            sca
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %EndBlock
    
    if(Parameters.trialrestart);
        Parameters = Preparescreen(Parameters);    %initialize the PTB screen
    end
    
    modeflag = 'EndBlock';
    evalstring=sprintf('%s(Parameters,Stimuli_sets,0,blocknum,modeflag,[],Block_Export,Trial_Export,FullUserdata.Demodata)',blocktype{1}); %sets up the stimuli and initializes other parameters
    [x2 Parameters x5  Block_Export Trial_Export ]= eval(evalstring);
    FullUserdata.Blocks(blocknum).Block_Export = Block_Export;
    
    blockfile = fopen(sprintf('%s.m',blocktype{1}),'r');
    
    FullUserdata.Blocks(blocknum).blockcode =  fscanf ( blockfile,'%c');
    fclose(blockfile);
    
catch Errormessage
    
    Priority(0);
    ListenChar(1);
    sca
    Showerror(Errormessage);
    Streamcleanup;
    try
        if ispc
            try
                ShowHideFullWinTaskbarMex(1);
            catch ME
                ShowHideWinTaskbarMex(1);
            end
        end
    end
    keyboard
    
end

end

