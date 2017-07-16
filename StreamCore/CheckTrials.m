function trialcheck = CheckTrials(Events,Stimuli_sets)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CheckTrials(Events,Stimuli_sets)
% Checks that the trial's stimuli and Events have proper values defined to run the trial sucdcessfully. 
%
% Input
%    Events: Structure containing information about all Events presented
%    Stimuli_sets: information about all of the stimuli created in the
%    block file
%
%CheckTrials is called by:
%    Runblock


%Set up catch flag
trialcheck.errormsg = [];
error = 0;



for(event = 1:length(Events.itemset))
    
    % does the stimuli set exist?
    if (Events.itemset(event) > length(Stimuli_sets))
        trialcheck.errormsg = 'You are attempting to display an item from a stimuli set that does not exist.';
        trialcheck.errormsg2 = sprintf('Attempted Set number %d on event %d',Events.itemset(event), event);
        
        
        error = 1;
        break
    end
    %stimulus set set to 0 (new_event_show_stimulus only)
    if (Events.itemset(event) == 0 && Events.action(event) == 1)
        trialcheck.errormsg = 'You are attempting display an item from or create a stimset with the number 0.';
        trialcheck.errormsg2 = 'Please only use positive intergetrs for your stimsets.';
        
        
        error = 1;
        break
    end
    
    % check timing
    if (Events.time(event) < 0)
        trialcheck.goodtrials = 0;
        trialcheck.errormsg = 'Event onset time is less than zero.';
        trialcheck.errormsg2 = sprintf('Event #%d',event);
        
        error = 1;
        break
        
    end
    % does the stimulus in the set exist? (new_event_show_stimulus only)
    
    if(Events.itemset(event) > 0 && Events.action(event) == 1)
        if (Events.itemnum(event) > length(Stimuli_sets(Events.itemset(event)).stimnames))
            trialcheck.errormsg = 'You are attempting to display a stimulus that does not exist in this stimuli set.';
            trialcheck.errormsg2 = sprintf('Set number %d, attempted item number %d',Events.itemset(event),Events.itemnum(event));
            
            error = 1;
            break
        end
    elseif Events.itemset(event) == 0 && Events.action(event) == 1
        trialcheck.errormsg = 'You are attempting to display a stimulus that does not exist in this stimuli set.';
        trialcheck.errormsg2 = sprintf('Set number %d, attempted item number %d',Events.itemset(event),Events.itemnum(event));
        
        error = 1;
        break
    end
    
    
    
end

if (error) % was there an error?
    
    sca;
    beep;
    StreamDebug = dbstack;
    disp(' ');
    disp('**************************************************');
    disp('**************************************************');
    disp('**             Event Errors Found               **');
    disp('**************************************************');
    disp('**************************************************');
    disp(' ');
    disp(trialcheck.errormsg);
    disp(trialcheck.errormsg2);
    disp(' ');
    disp('**************************************************');
    disp('**************************************************');
    disp('**************************************************');
    disp('**************************************************');
    disp(' ');
    ListenChar(1);
    try
        if ispc
            try
                ShowHideFullWinTaskbarMex(1);
            catch ME
                ShowHideWinTaskbarMex(1);
            end
        end
    end
    
    keyboard;
    
end