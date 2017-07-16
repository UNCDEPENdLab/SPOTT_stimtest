function Events= showstream(Parameters,Events,Stimuli_sets,fileprefix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Michael Hess, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Showstream(Parameters,Events,Stimuli_sets,fileprefix)
% Showstream does the work of presenting Stimuli on screen according to the
% schedule in Events for a single trial
%
% as it does so, it keeps track of the timestamps at which each stimulus was
% actually displayed to the user (which can differ from the scheduled time)
%
% You should not edit this file in a significant way unless you are quite
% sure what you are doing  -Brad W.
%
% Input
%    Parameters: Parameter set for this experiment if previously set
%    Events:  The list of events to display on THIS trial
%    this function will modify Events by adding several extra variables for
%    time bookkeeping:  Events.timeused, Events.timepasted, Events.flipped
%    Stimuli_sets: Structure containing all of the information about the
%    stimuli in the experiment
%    fileprefix: the prefix name of any file sent here
%
%Showstream is called by:
%    Runblock

if(IsOSX)  %these are commented out because priority changes have caused timing errors
    %      Priority(9);
elseif(IsLinux)
    % Priority(2);
else
    %    Priority(2);
end

KbName('UnifyKeyNames');
if(IsOSX)
    enterkey = 'ENTER';
else
    enterkey = 'Return';
end


%Figure out if there is a backspace key
try
    backkey = KbName('Backspace');
catch
    backkey =-999;
end
esccode = KbName('ESCAPE');

%Set up placeholder values for fields that may not be created in the data file
Events.time = Events.time * Parameters.slowmotionfactor;
Events.timeflipped = 0;
Events.timequeued = zeros(length(Events.time),1);
Events.pasted = zeros(length(Events.time),1);
Events.flipped = zeros(length(Events.time),1);
Events.Eyedata.X = 0;
Events.Mousedata.X = 0;
Events.keystrokes = cell(length(Events.time),1);
Events.keystrokestime = cell(length(Events.time),1);
Events.keypresses = [0];
Events.keypresstimes = [0];


%do some checks to make sure things are going to work well
speedoptimizedmode = Parameters.speedoptimized;


numevents = length(Events.time);
Movietimepoints{1} = 0;
[ keyIsDown, seconds, lastkeyCode ] = KbCheck(-1);


%initialize the eye tracker data if we're using it
if(Parameters.eyetracking & Parameters.eyerealtime & Parameters.eyedatastore)
    duration = Events.time(end) - Events.time(1);
    numpoints = Parameters.eyesamplingrate * duration;
    Eyedata.X = zeros(numpoints,1);
    Eyedata.Y = zeros(numpoints,1);
    Eyedata.Time = zeros(numpoints,1);
    
end
resetDatapixxDin = 0;  %used to reset Datapix DIN outputs back to 0


if(Parameters.eyetracking)
    if(Parameters.Eyelink)
        Eyelink('StartRecording');
        eye_used = Eyelink('EyeAvailable');
        while(eye_used==-1)
            eye_used = Eyelink('EyeAvailable');
        end
        eyeX = 0;
        eyeY = 0;
    elseif(Parameters.TobiiX2)
        tetio_startTracking;
        eyeX = 0;
        eyeY = 0;
    end
end

%set up transparency
Screen('blendfunction',Parameters.window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%initialize the mouse data if we're using it

cursorsize = Parameters.mouse.cursorsize;
if(Parameters.mouse.enabled)
    [Mousedatax,Mousedatay,buttons] = GetMouse(Parameters.window);  %get the current mouse position
    theY = Mousedatay; theX=Mousedatax;
    cursorsize = Parameters.mouse.cursorsize;  %how big is the cursor?
    mousecounter = 1;
    if(Parameters.mouse.datastore)    %if we are storing the mouse information, initialize these arrays
        Mousedata.Time(mousecounter) = GetSecs();
        Mousedata.X(mousecounter) = Mousedatax;
        Mousedata.Y(mousecounter) = Mousedatay;
        mouseclicks = 0;
    end
    button1wasdown = 0;
    newbutton = 0;
end


for(i = 1:length(Events.time))
    Events.keystrokes{i} = 0;
    Events.keystrokestime{i} = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First, initialize some variables for the main loop from which shows the successive events in the trial

redrawflag = 0;    %this will be set to 1 whenever we need showstream to redraw the current display (for example if the mouse cursor moves)
%are we currently waiting for a response

numkeypresses = 0;   % index of keypresses not associated with events
keywasdown = 1;      %if this is 1, we can't accept new keypresses until there's been no key-presses
ThisBatchofEvents = [];   %events which are currently visible on the screen
Extratriggers = [];  %each keypress produces an ParallelPort trigger, this list is used to keep track of them

%various flags used by different portions of the timing loop
firstdrawn = 0;
responsekey = 0;  %these flags indicate whether we're waiting for a response
responsepausetime = 0; %does time wait for a response
mouse_responsepausetime = 0; %does time wait for a response
responsemouse = 0;
responsekeyopen = 0;
responseeye =0;  %used to signal if we are waiting for an eye reaction time
flipneeded = 0; %does this event need the screen flipped
zeromarkertime = 0;
markersend = 0; %send Parallel port marker
markeronline = 0;
markerreset = 0;
eventready = zeros(numevents,1);
eyedatacounter = 0;
oldeyeX = 0;oldeyeY = 0;
ScreenshotQueued = 0;
Movieplaying = 0;
Firstdrawevent = 0;  %sets to 1 if a new event has been put on the screen
response_DIN_event = 0;
responsebegin =0; %begin the collection of the response
responsebegin_mouse = 0; %begin the collection of the response

Moviestarttime = 0;
Audiostartneeded = 0;
Audiostarttime = 0;

lastuseCursor = 0;  % history of eye cursor
useCursor = 0;

%Screen('Flip', Parameters.window);
starttime = GetSecs();   %what time is it now?
lastfliptime = starttime;
Events.timeused = Events.time + starttime;   %do all Event timing relative to start-time
Flipreadytime = .009;  %at what point do we commit to the next flip?
if(speedoptimizedmode)
    %  Flipreadytime = .9;
end

Flipready = 0;



speedfliptime = inf;
speedeventsshown = 1;

[keyIsDown, keyTime, keyCode ] = KbCheck(-1);


audiowait = 0;
soundwait = 0;
alldone = 0;

if(isfield(Events,'variableNames') == 0);
    Events.variableNames = [];
end

if(isfield(Events,'variableInputByEv') == 0);
    Events.variableInputByEv = [];
end
if(isfield(Events,'variableVal') == 0);
    Events.variableVal{1} = 0;
end
if(isfield(Events,'variableFunctions') == 0);
    Events.variableFunctions{1} = '';
end
if(isfield(Events,'variableUpdateTime') == 0);
    Events.variableUpdateTime(1) = 0.1;
end
if(isfield(Events,'variableStartUpdate') == 0);
    Events.variableStartUpdate(1) = 0;
end
if(isfield(Events,'variableStopUpdate') == 0);
    Events.variableStopUpdate(1) = 9999999;
end


variablesUpdated = 0;
for(varnum = 1:length(Events.variableNames))
    if(varnum > length(Events.variableUpdateTime))
        Events.variableUpdateTime(varnum) = .1;
    end
    if(varnum > length(Events.variableVal))
        Events.variableVal{varnum} = 0;
    end
    if(varnum > length(Events.variableFunctions))
        Events.variableFunctions{varnum} = '';
    end
    if(varnum > length(Events.variableStartUpdate))
        Events.variableStartUpdate(varnum) = 0;
    end
    if(varnum > length(Events.variableStopUpdate))
        Events.variableStopUpdate(varnum) = 9999999;
    end
    
    Events.variableLastUpdated(varnum) = 0;
    
    Events.variableOutput{varnum} = [];
    Events.variableOutputType{varnum} = [];
    %find dynvar outputs
    for(ev = 1: length(Events.itemset))
        if(Events.location(1,ev) == -1*varnum)   %output var 1 is xloc
            Events.variableOutput{varnum} = [Events.variableOutput{varnum} ev];
            Events.variableOutputType{varnum} = [Events.variableOutputType{varnum} 1];
        end
        if(Events.location(2,ev) == -1*varnum)   %output var 2 is yloc
            Events.variableOutput{varnum} = [Events.variableOutput{varnum} ev];
            Events.variableOutputType{varnum} = [Events.variableOutputType{varnum} 2];
        end
        if(Events.itemnum(ev) == -1*varnum) %output var 3 is itemnum
            Events.variableOutput{varnum} = [Events.variableOutput{varnum} ev];
            Events.variableOutputType{varnum} = [Events.variableOutputType{varnum} 3];
        end
        if(Events.itemset(ev) == -1*varnum) %output var 4 is itemset
            Events.variableOutput{varnum} = [Events.variableOutput{varnum} ev];
            Events.variableOutputType{varnum} = [Events.variableOutputType{varnum} 4];
        end
    end
    %find dynvar inputs
    Events.variableInput{varnum} = [];
    Events.variableInput_type{varnum} = [];
    for(ev = 1: length(Events.variableInputByEv))
        
        if(Events.variableInputByEv(ev) == varnum)
            Events.variableInput{varnum} = [Events.variableInput{varnum} ev];
            Events.variableInputMapping{varnum}{length(Events.variableInput{varnum})} = Events.variableInputMappingByEv{ev};  %what kind of mapping is it?
        end
    end
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%THE LOOP

time_to_flip = 0;
while(alldone ==0)    %loop through all of the events
    
    if(Parameters.interruptible & keyCode(esccode))   %if someone pressed escape during the previous trial, break us out of here
        sca %shutdown psychtoolbox
        error('User aborted');
        PsychPortAudio('Stop',Parameters.pahandle);
        
    end
    
    nowtime = GetSecs;  %we collect the current time at the top of each loop
    
     for(varnum = 1: length(Events.variableNames))
        if(nowtime - Events.variableLastUpdated(varnum) > Events.variableUpdateTime(varnum) | variablesUpdated) & (nowtime > Events.variableStartUpdate(varnum))& (nowtime < Events.variableStopUpdate(varnum)) 
            
            varmatch = intersect(Events.variableOutput{varnum}, ThisBatchofEvents);  %which variables have output events that are active
            varmatch = Events.variableOutput{varnum};  %which variables have output events that are active
            
            for(evnum = varmatch)
                varindex = find(Events.variableOutput{varnum} ==  evnum);
                
                %Execute dynamic variables if they are present in current event
                if(length(Events.variableFunctions{varnum}) > 0)
                    Events.variableVal{varnum} = eval(Events.variableFunctions{varnum});
                end
                
                switch(Events.variableOutputType{varnum}(varindex))
                    case{1} %locx
                        Events.location(1,evnum) = Events.variableVal{varnum};
                        if( Events.action(evnum) ==2)
                            responsex =  Events.location(1,evnum);
                        end
                    case{ 2} %locy
                        Events.location(2,evnum) = Events.variableVal{varnum};
                        if( Events.action(evnum) ==2)
                            responsex =  Events.location(2,evnum);
                        end
                    case{3}  %itemnum
                        Events.itemnum(evnum) = Events.variableVal{varnum};
                    case{4}  %set
                        Events.itemset(evnum) = Events.variableVal{varnum};
                end
            end
            Events.variableLastUpdated(varnum)  = nowtime;
            redrawflag = 1;
            flipneeded = 1;
                        
        end
        
    end
    variablesUpdated = 0;
    
    nowtime = GetSecs;  %we collect the current time at the top of each loop
    
    
    
    %now figure out which events have become current
    timeElapsed_inflip = rem(nowtime-lastfliptime,Parameters.fliptime);
    
    nextflipwillbe = nowtime + (Parameters.fliptime- timeElapsed_inflip);   %when will the monitor be ready to flip next??
    
    
    if(responsepausetime ==0 & mouse_responsepausetime ==0&  responseeye ==0 & response_DIN_event ==0 & soundwait == 0)
        sched = Events.timeused-(nextflipwillbe);   %subtract the next flip time from each event
        %sched = Events.timeused-nowtime-.008;%(nextflipwillbe);   %subtract the next flip time from each event
        notshownevents = eventready ==0;   %which events have not yet occurred?
        tobeshown_events = sched(notshownevents);   %this is the list of remaining times of those events
        
        %but plan ahead to put something on the screen if it will happen before the next flip begins
            %these things need to be true:
            %next events time will be current before the flip
            %it hasn't already been shown
            %there are no other events scheduled prior to it
            %i.e. if two stimuli are 1 millisecond apart, they will be shown on subsequent frames
            for(checkevent = 1:numevents)
                if(sched(checkevent) <=0 & eventready(checkevent) ==0 & sched(checkevent) == min(tobeshown_events))
                    eventready(checkevent) = 1;
                    time_to_flip = Events.timeused(checkevent);
                end
            end
        
    end
    
    
    
    
    %We have found at least one event that is scheduled to happen now  (also check to make sure that we are not waiting for a response, which will defer all events)
    if(max(eventready==1) & responsepausetime ==0 &  mouse_responsepausetime ==0 & responseeye ==0& soundwait ==0)
        
        
        
        %accumulate a list of events that will need to be redrawn if we want to redisplay current screen
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %Go through the list of events and execute all of them that are
        %current
        
        for(doevent = 1:length(eventready))
            
            if(eventready(doevent)==1)
                
                switch(Events.action(doevent))              %what kind of action are we currently displaying?
                    case -1  % end of the stream, do nothing
                        Events.timepasted(doevent) = GetSecs-starttime;   %record which time the event was put on the back buffer
                        Events.timeflipped(doevent) = 999;
                        % flipneeded = 1;
                        % Screen('Flip', Parameters.window);
                        alldone = 1;
                        if(Movieplaying)
                            Screen('PlayMovie', Moviepointer, 0);
                        end
                        Events.timeflipped(find(Events.timeflipped == 999)) = GetSecs-starttime;
                        Events.timepasted(find(Events.timepasted == 999)) = GetSecs-starttime;
                        
                    case 0   %make up your own action!
                        
                    case 1    %display something on the screen (newevent_show_stimulus)
                        
                        
                        %if eventclear == 0
                        %  clear the screen of all other stimuli
                        % otherwise leave previous stimuli on the
                        % screen
                        if(Events.eventclear(doevent) ==0)
                            ThisBatchofEvents = [];
                            currentvarnum = 0;
                        end
                        
                        if(length(ThisBatchofEvents) ==0)
                            Firstdrawevent = doevent;
                        end
                        ThisBatchofEvents = [ThisBatchofEvents, doevent];
                        
                        redrawflag = 1; %set flag to draw these items on the screen
                        firstdrawn = 1;
                        flipneeded = 1;
                        
                        %If itemset is not dynamic then process event
                        %normally
                        if Events.itemset(doevent) > 0 && Events.itemnum(doevent)> 0
                            stimset = Events.itemset(doevent);  %figure out which stimulus set and number
                            stimnum = Events.itemnum(doevent);
                        end
                        if( Stimuli_sets(stimset).type ==4)   %it's a movie
                            Screen('PlayMovie', Stimuli_sets(stimset).pointer(stimnum), 1, 0, 1.0);
                            Screen('SetMovieTimeIndex', Stimuli_sets(stimset).pointer(stimnum), 0);
                            Movieplaying = 1;
                            Moviestarttime = -99;
                            Moviepointer = Stimuli_sets(stimset).pointer(stimnum);
                            % compute duration
                            Movietime = Stimuli_sets(stimset).stimsize(stimnum);
                            Movieframes = Movietime / Parameters.fliptime;
                            Movietimepoints{doevent} = zeros(Movieframes,1);
                            Movieframecounter = 0;
                            Movieevent = doevent;
                        end
                        
                        if( Stimuli_sets(stimset).type ==5)  %an audio stimulus
                            audioevent = doevent;
                            audiowait = Stimuli_sets(stimset).audiowait(stimnum);
                            if(audiowait ==1)  %is this a stimulus that will force us to wait until its over?
                                soundwait = 1;
                            end
                            PsychPortAudio('Stop',Parameters.pahandle);%stop buffer if previously started
                            PsychPortAudio('FillBuffer', Parameters.pahandle, Stimuli_sets(stimset).pointer(stimnum));%restart buffer
                            %   redrawneeded = 1; %force a redraw of all stimuli on the screen
                            %   flipneeded = 1;
                            Audiostartneeded = 1;
                        end
                        eventready(doevent) = 2;
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = 999;
                        Events.timeflipped(doevent) = 999;
                        
                    case 2        %Keyboard response event (newevent_keyboard)
                        if(Parameters.disableinput ==0)
                            %dynamic variables for response events
                            %initialized here:
                            %Collect information about the event from the
                            %responsestruct
                            responsekeyopen = doevent; %a response event is currently open
                            responsekey = 1;
                            responsepausetime = Events.pausetime(doevent);
                            responseendproductlength = 0;
                            responsekeystrokeslength = 0;
                            responsex = Events.location(1,doevent);
                            responsey = Events.location(2,doevent);
                            responsefont = Events.font{doevent};
                            responsefontsize = Events.fontsize(doevent);
                            responseminlength = Events.minlength(doevent);
                            responsemaxlength = Events.maxlength(doevent);
                            responseshowinput = Events.showinput(doevent);
                            responseallowbackspace = Events.allowbackspace(doevent);
                            responsewaitforenter = Events.waitforenter(doevent);
                            responsekeys = Events.allowedchars{doevent};
                            responseuppercase = Events.uppercase(doevent);
                            responseendtrial = Events.endtrial(doevent);
                            responseclearscreen = Events.clearscreen(doevent);
                            
                            responsekeystrokes = [];
                            responseendproduct = [];
                            responsetimestamps = [0];
                            responseconversion = Events.conversion{doevent};
                            if Events.timeout(doevent)  == 0
                                responseend = 9999 + GetSecs;
                            else
                                responseend = Events.timeout(doevent) + GetSecs;
                            end
                            responsebegin = Events.mintime(doevent) + GetSecs;
                            
                            
                            responsenag = 0;
                            responsestarttime = GetSecs;
                            numerrors = 0;
                            responseevent = doevent;
                        else  %Disable input enabled
                            Events.response(doevent) = 0;
                            Events.responsert{doevent} = 0;
                            responsekeystrokes = [0];
                            responseendproduct = [0];
                            
                        end
                        Events.timequeued(doevent) = GetSecs-starttime;
                        
                        Events.timepasted(doevent) = GetSecs-starttime;
                        Events.timeflipped(doevent) = 998; %record which time the event was put on the back buffer
                        eventready(doevent) = 2;
                        
                        
                        
                        
                    case 3     %Mouse click response (newevent_mouse)
                        
                        if(Parameters.disableinput ==0)
                            responsemouse = 1;
                            if Events.timeout(doevent)  == 0
                                response_mouse_end = 999999 + GetSecs;
                            else
                                response_mouse_end = Events.timeout(doevent) + GetSecs;
                            end
                            %collect information about the event from the
                            %responsestruct
                            mouse_responsepausetime = Events.pausetime(doevent);
                            response_mouse_windows = Events.spatialwindows{doevent};
                            response_mouse_window_counters = zeros(length(Events.spatialwindows{doevent}),1)+ 999999;
                            response_mouse_window_mintime  = Events.spatialwindows_mintime{doevent};
                            
                            response_mouse_starttime = GetSecs;
                            num_mouse_errors = 0;
                            response_mouse_event = doevent;
                            responsebegin_mouse = Events.mintime(doevent) + GetSecs;
                            responseclearscreen_mouse = Events.clearscreen(doevent);
                            [Mousedatax,Mousedatay,buttons] = GetMouse(Parameters.window);
                            while(buttons(1))
                                [Mousedatax,Mousedatay,buttons] = GetMouse(Parameters.window);
                            end
                        else  %input disabled
                            Events.mouse_response{doevent} = [-1 -1];
                            Events.mouse_rt(doevent) =0;
                        end
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;
                        Events.timeflipped(doevent) = 997; %record which time the event was put on the back buffer
                        eventready(doevent) = 2;
                        
                    case 4     %send an ParallelPort marker (newevent_ParallelPort_mark)
                        if(markeronline ==0 & GetSecs > markerreset)   %if there is no active ParallelPort marker, schedule this one to fire
                            markersend = Events.itemnum(doevent);
                            Events.timequeued(doevent) = GetSecs-starttime;
                            
                            Events.timepasted(doevent) = GetSecs-starttime;
                            markerevent = doevent;
                            markeronline = 1;
                            eventready(doevent) = 2;
                        else                  %The trigger port is busy handling a prior marker, so wait to send this one for 1 millisecond by bumping the time a bit later
                            
                            Events.timeused(doevent) =   GetSecs + .001;
                            eventready(doevent) = 0;
                        end
                        
                    case 5 %(newevent_eye_message)
                        if(Parameters.Eyelink & Parameters.eyetracking)
                            Eyelink('Message', Events.eye_message{doevent});
                        end
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;
                        Events.timeflipped(doevent) = GetSecs-starttime;
                        eventready(doevent) = 2;
                    case 6 %newevent_gaze
                        %gaze contingent... collect a saccadic reaction
                        
                        if(Parameters.disableinput ==0)
                            
                            responseeye = 1;
                            if Events.timeout(doevent)  == 0
                                response_eye_end = 999999 + GetSecs;
                            else
                                response_eye_end = Events.timeout(doevent) + GetSecs;
                            end
                            %collect information about the event from the
                            %responsestruct
                            eye_responsepausetime = Events.pausetime(doevent);
                            response_eye_windows = Events.spatialwindows{doevent};
                            response_eye_window_counters = zeros(length(Events.spatialwindows{doevent}),1)+ 999999;
                            response_eye_window_mintime  = Events.spatialwindows_mintime{doevent};
                            
                            response_eye_starttime = GetSecs;
                            num_eye_errors = 0;
                            response_eye_event = doevent;
                            responsebegin_eye = Events.mintime(doevent) + GetSecs;
                            responseclearscreen_eye = Events.clearscreen(doevent);
                        else  %input disabled
                            Events.eye_response{doevent} = [-1 -1];
                            Events.eye_rt(doevent) =0;
                        end
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;
                        Events.timeflipped(doevent) = 996; %record which time the event was put on the back buffer
                        eventready(doevent) = 2;
                        
                    case 7
                        % blank event (newevent_blank)
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;   %record which time the event was put on the back buffer
                        Events.timeflipped(doevent) = 999;
                        ThisBatchofEvents = [];
                        currentvarnum = 0;
                        % flipneeded = 1;
                        % Screen('Flip', Parameters.window);
                        redrawflag = 1;
                        flipneeded = 1;
                        firstdrawn = 1;
                        eventready(doevent) = 2;
                        
                        
                    case 8
                        % mousecursor event (newevent_mouse_cursor)
                        Parameters.mouse.cursorsize = Events.cursorsize(doevent);
                        cursorsize = Parameters.mouse.cursorsize;
                        SetMouse(Events.mousex(doevent),Events.mousey(doevent));
                        Events.timepasted(doevent) = GetSecs-starttime;   %record which time the event was put on the back buffer
                        Events.timeflipped(doevent) = 999;
                        %flipneeded = 1;
                        %Screen('Flip', Parameters.window);
                        eventready(doevent) = 2;
                        
                        
                    case 27
                        %command events (newevent_command)
                        redrawflag = 1; %set flag to draw these items on the screen
                        if(Events.eventclear(doevent) ==0)
                            ThisBatchofEvents = [];
                            currentvarnum = 0;
                        end
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;
                        firstdrawn = 1;
                        flipneeded = 1;
                        eval(Events.command{doevent});
                        Events.timeflipped(doevent) = 999;
                        eventready(doevent) = 2;
                        ThisBatchofEvents = [ThisBatchofEvents, doevent];
                        
                        
                    case 98
                        %DIN on Datapixx (newevent_Datapixx_DIN)
                        response_DIN_end = Events.eventclear(doevent)+GetSecs;
                        response_DIN_pin1 = 24-Events.eye_message{doevent};
                        response_DIN_pin2 = 24-Events.misc3(doevent);
                        response_DIN_value = Events.misc4(doevent);
                        response_DIN_starttime = GetSecs;
                        response_DIN_event = doevent;
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;   %record which time the event was put on the back buffer
                        Events.timeflipped(doevent) = GetSecs-starttime;
                        eventready(doevent) = 2;
                        Events.mouse_response(response_DIN_event) = 0;
                        
                    case 99
                        % Queue up a CM5 event
                        CM5Amplitude = Events.eventclear(doevent);
                        CM5Frequency = Events.eye_message{doevent};
                        CM5Duration = Events.misc3(doevent);
                        CM5which = Events.misc4(doevent);
                        for(bitcount = 1:4)
                            stim{bitcount} = Parameters.CM5stim.Clone;
                        end
                        stim{CM5which}.Amplitude = CM5Amplitude;
                        stim{CM5which}.Frequency = CM5Frequency;
                        stim{CM5which}.Duration = CM5Duration;
                        
                        Parameters.CM5.SimpleVibration(stim{1},stim{2},stim{3},stim{4});
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;
                        Events.timeflipped(doevent) = 999; %record which time the event was put on the back buffer
                        eventready(doevent) = 2;
                    case 100
                        % Queue up a CM5 event
                        if(Parameters.useCM5)
                            Datapixx('SetDinDataOut',65536)
                            Datapixx('RegWrRd')
                            resetDatapixxDin = GetSecs;
                        end
                        
                        Events.timequeued(doevent) = GetSecs-starttime;
                        Events.timepasted(doevent) = GetSecs-starttime;
                        Events.timeflipped(doevent) = 999; %record which time the event was put on the back buffer
                        eventready(doevent) = 2;
                end
                if(Events.screenshot(doevent))  %take a screenshot if this event asks us to.
                    ScreenshotQueued = 1;
                    
                end
            end
        end
    end
    
    %process dynamic variables
    
   
    
    %if there are other events to send (due to mouse clicks or buttons)
    if(~isempty(Extratriggers) & markeronline ==0 &  GetSecs > markerreset)
        markersend = Extratriggers(1);
        markerevent = -10;
        markeronline = 1;
        Extratriggers = Extratriggers(2:length(Extratriggers));
    end
    
    if(Movieplaying)
        frametodraw = 0;
        
        if (GetSecs-Moviestarttime <= Movietime-.1 |Moviestarttime == -99 )
            [tex pts] = Screen('GetMovieImage', Parameters.window, Moviepointer, 0, [], 0, 1);
        else
            tex = 0; %-1;
        end
        % Valid texture returned?
        if tex>0
            % Draw the new texture immediately to screen:
            flipneeded = 1;
            redrawflag = 1;
            frametodraw = tex;
            Movieframecounter = Movieframecounter+1;
            % Movieplaying = 0;
        elseif tex == 0
            Movieframecounter = Movieframecounter+1;
        elseif tex ==-1
            %    if(IsOSX)
            %    Screen('PlayMovie', Stimuli_sets(stimset).pointer(stimnum), 0, 0, 1.0);
            %   end
            Movieplaying = 0;
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Something has triggered the redraw flag
    %Go through the list of events that are currently on the screen and
    %redraw them all  (seems decadent, but computers are fast)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(redrawflag)
        if(Movieplaying)
            if(frametodraw > 0)
                Screen('DrawTexture', Parameters.window, frametodraw);
                Screen('Close',frametodraw);
            end
        end
        
        for(doevent = ThisBatchofEvents)         %loop through the active stimuli on  screen and draw all of'em
            if (Events.action(doevent) == 27)
                eval(Events.command{doevent});
            else
                
                
                stimset = Events.itemset(doevent);
                stimnum = Events.itemnum(doevent);
                stimx = Events.location(1,doevent);
                stimy = Events.location(2,doevent);
                stimxdim = Stimuli_sets(stimset).xdim(stimnum);
                stimydim = Stimuli_sets(stimset).ydim(stimnum);
                stimsize = Stimuli_sets(stimset).stimsize(stimnum);
                if(Stimuli_sets(stimset).type ==2)   %if it's a drawtext Stimuli, configure the parameters appropriately
                    Screen('TextSize',Parameters.window,stimsize);
                    Screen('TextColor',Parameters.window,Stimuli_sets(stimset).color(1:3,stimnum));
                    Screen('TextFont',Parameters.window,Stimuli_sets(stimset).font{stimnum});
                    if(stimx == -1000)  %draw it at the mouse location
                        Screen('DrawText', Parameters.window, Stimuli_sets(stimset).stimnames{stimnum}, Mousedatax,Mousedatay);
                    elseif(stimx ==-2000) %draw it at the eye location
                        Screen('DrawText', Parameters.window, Stimuli_sets(stimset).stimnames{stimnum}, eyeX,eyeY);
                    else
                        %  DrawFormattedText(win, tstring, sx, sy, color, wrapat, flipHorizontal, flipVertical, vSpacing, righttoleft, winRect)
%                         if Stimuli_sets(stimset).wrapat(stimnum) ==0 && Stimuli_sets(stimset).vSpacing(stimnum) == 0
                        Screen('DrawText', Parameters.window, Stimuli_sets(stimset).stimnames{stimnum}, stimx-stimxdim/2,stimy-stimydim/2);
%                         else
%                         DrawFormattedText(Parameters.window,Stimuli_sets(stimset).stimnames{stimnum},stimx-stimxdim/2,stimy-stimydim/2,[],Stimuli_sets(stimset).wrapat(stimnum),0,0,Stimuli_sets(stimset).vSpacing(stimnum),0);
%                         end
                        
                    end
                elseif (Stimuli_sets(stimset).type ==1)  %it's a texture
                    lj = Stimuli_sets(stimset).leftjustify(stimnum);
                    bj = Stimuli_sets(stimset).bottomjustify(stimnum);
                    
                    
                    if(lj)
                        x1 = stimx;x2 = stimx + stimxdim*stimsize;
                    else
                        x1 = stimx-stimxdim/2*stimsize; x2 = stimx+stimxdim/2*stimsize;
                    end
                    if(bj)
                        y1 = stimy - stimydim*stimsize; y2 = stimy;
                    else
                        y1 = stimy-stimydim/2*stimsize; y2 = stimy+stimydim/2*stimsize;
                    end
                    Screen('DrawTexture', Parameters.window, Stimuli_sets(stimset).pointer(stimnum),[0 0 stimxdim stimydim],[x1 y1 x2 y2],Stimuli_sets(stimset).rotate(stimnum),Parameters.textureFilterMode);
                elseif (Stimuli_sets(stimset).type ==7)   %it's a texture
                    Screen('DrawTexture', Parameters.window, Stimuli_sets(stimset).pointer(stimnum),[0 0 stimxdim stimydim],[stimx-stimxdim/2*stimsize stimy-stimydim/2*stimsize stimx+stimxdim/2*stimsize  stimy+stimydim/2*stimsize],0,Parameters.textureFilterMode);
                elseif( Stimuli_sets(stimset).type == 3)    %stimtype is 3, draw a PTB shape, in this case a dot
                    shape = Stimuli_sets(stimset).stimnames{stimnum};
                    xdim = Stimuli_sets(stimset).xdim(stimnum);
                    ydim = Stimuli_sets(stimset).ydim(stimnum);
                    stimx = Events.location(1,doevent);
                    stimy = Events.location(2,doevent);
                    color = Stimuli_sets(stimset).color(1:3,stimnum);
                    linewidth = Stimuli_sets(stimset).linewidth(stimnum);
                    stimsize = Stimuli_sets(stimset).stimsize(stimnum);
                    
                    switch(shape)
                        case 'DrawLine'
                            linelength = Stimuli_sets(stimset).linelength(stimnum);
                            lineangle = Stimuli_sets(stimset).lineangle(stimnum);
                            
                            endpointx = cos(lineangle*(pi/180)) *linelength;
                            endpointy = sin(lineangle*(pi/180)) *linelength;
                            
                            midpointx = endpointx/2;
                            midpointy = endpointy/2;
                            
                            x1 = stimx - midpointx;
                            y1 = stimy - midpointy;
                            
                            x2 = stimx + midpointx;
                            y2 = stimy + midpointy;
                            
                            
                            
                            Screen('DrawLine', Parameters.window, color, x1, y1, x2, y2, linewidth);
                        case 'DrawArc'
                        case 'FrameArc'
                        case 'FillArc'
                        case 'FillRect'
                            Screen('FillRect', Parameters.window, color, [stimx-(xdim/2)*stimsize,stimy-(ydim/2)*stimsize,stimx+(xdim/2)*stimsize,stimy+(ydim/2)*stimsize]);
                        case 'FrameRect'
                            Screen('FrameRect', Parameters.window, color, [stimx-(xdim/2)*stimsize,stimy-(ydim/2)*stimsize,stimx+(xdim/2)*stimsize,stimy+(ydim/2)*stimsize], linewidth);
                        case 'FillOval'
                            Screen('FillOval', Parameters.window, color, [stimx-(xdim/2)*stimsize,stimy-(ydim/2)*stimsize,stimx+(xdim/2)*stimsize,stimy+(ydim/2)*stimsize]);
                        case 'FrameOval'
                            Screen('FrameOval', Parameters.window, color, [stimx-(xdim/2)*stimsize,stimy-(ydim/2)*stimsize,stimx+(xdim/2)*stimsize,stimy+(ydim/2)*stimsize], linewidth);
                        case 'FramePoly'
                            pointlistx = Stimuli_sets(stimset).pointlist{stimnum}(:,1)*stimsize;
                            pointlisty = Stimuli_sets(stimset).pointlist{stimnum}(:,2)*stimsize;
                            polyxdim = max(pointlistx)+min(pointlistx);
                            polyydim = max(pointlisty)+min(pointlisty);
                            Screen('FramePoly', Parameters.window, color, [(pointlistx + stimx - polyxdim/2), (pointlisty + stimy - polyydim/2)],linewidth);
                        case 'FillPoly'
                            pointlistx = Stimuli_sets(stimset).pointlist{stimnum}(:,1)*stimsize;
                            pointlisty = Stimuli_sets(stimset).pointlist{stimnum}(:,2)*stimsize;
                            polyxdim = max(pointlistx)+min(pointlistx);
                            polyydim = max(pointlisty)+min(pointlisty);
                            Screen('FillPoly', Parameters.window, color, [(pointlistx + stimx - polyxdim/2), (pointlisty + stimy - polyydim/2)]);
                    end
                elseif(Stimuli_sets(stimset).type ==4)  %it's a movie!
                    %do nothing, it's a movie
                    %             elseif(Stimuli_sets(stimset).type ==7)  %it's a Procedural Gabor
                    %                 %x,y dim = stimsize
                    %                 % orientation = font
                    %                 % bgcolor = color
                    %                 % contrast =clippingboundary
                    %                 % phase =transparencythreshold
                    %
                    %                 stimx = Events.location(1,doevent);
                    %                 stimy = Events.location(2,doevent);
                    %                 xw = Stimuli_sets(stimset).stimsize(1,stimnum);
                    %                 yw = Stimuli_sets(stimset).stimsize(1,stimnum);
                    %                 freq = Stimuli_sets(stimset).stimnames(stimnum);
                    %                 orientation = Stimuli_sets(stimset).font(stimnum);
                    %                 bgcolor = Stimuli_sets(stimset).color(1:4,stimnum);
                    %                 contrast = Stimuli_sets(stimset).clippingboundary(stimnum);
                    %                 phase = Stimuli_sets(stimset).transparencythreshold(stimnum);
                    %                 Angle = orientation;
                    %                 dstRect = OffsetRect([1, 1,xw, yw],stimx,stimy);
                    %                 DontRotate = 1;
                    %                 % Screen('DrawTexture', win, gabortex, [], [], 90+tilt, [], [], [], [], kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
                    %                 Screen('DrawTexture',  Parameters.window, Stimuli_sets(stimset).pointer(stimnum), [], [], Angle,[],[] , [], [],DontRotate,[phase,freq,50,contrast,50,0,0,0]);
                elseif (Stimuli_sets(stimset).type ==5)
                elseif (Stimuli_sets(stimset).type ==6)
                    
                    
                    
                    %                 lj = Stimuli_sets(stimset).leftjustify(stimnum);
                    %                 bj = Stimuli_sets(stimset).bottomjustify(stimnum);
                    %
                    %
                    %                 if(lj)
                    %                     x1 = stimx;x2 = stimx + stimxdim*stimsize;
                    %                 else
                    %                     x1 = stimx-stimxdim/2*stimsize; x2 = stimx+stimxdim/2*stimsize;
                    %                 end
                    %                 if(bj)
                    %                     y1 = stimy - stimydim*stimsize; y2 = stimy;
                    %                 else
                    %                     y1 = stimy-stimydim/2*stimsize; y2 = stimy+stimydim/2*stimsize;
                    %                 end
                    %
                    Screen('DrawTexture', Parameters.window, Stimuli_sets(stimset).pointer(stimnum),[0 0 stimxdim stimydim],[stimx-stimxdim/2*stimsize stimy-stimydim/2*stimsize stimx+stimxdim/2*stimsize  stimy+stimydim/2*stimsize],0,Parameters.textureFilterMode);
                    
                else
                    MyShowstream;
                end
                if(Events.timepasted(doevent) == 999)   %if this is the first time this event was put on the screen, note the time
                    Events.timepasted(doevent) = GetSecs-starttime;
                end
            end
        end
        
        if responsekey & length(responseendproduct) > 0 &  responseshowinput
            Screen('TextSize',Parameters.window,responsefontsize);
            % Screen('TextColor',Parameters.window,Stimuli_sets(stimset).color(1:3,stimnum));
            Screen('TextFont',Parameters.window,responsefont);
            Screen('DrawText', Parameters.window, responseendproduct, responsex,responsey);
            %draw keyresponse stuff if necessary
        end
        
        if(Parameters.mouse.enabled & Parameters.mouse.cursorsize >0 )%draw the mouse cursor
            Screen('Frameoval',Parameters.window, Parameters.mouse.cursorcolor,[Mousedatax-cursorsize,Mousedatay-cursorsize,Mousedatax+cursorsize,Mousedatay+cursorsize],3);
        end
        if(Parameters.eyetracking & useCursor & Parameters.eyerealtime)
            Screen('Frameoval',Parameters.window, Parameters.eyecursorcolor,[eyeX-cursorsize,eyeY-cursorsize,eyeX+cursorsize,eyeY+cursorsize],3);
        end
        
        if( ScreenshotQueued == 1)
            imagearray=Screen('GetImage',Parameters.window,[0 0 Parameters.centerx*2 Parameters.centery*2],'backBuffer');
            fid = 1;
            screenshotname_count = 0;
            while(fid>0)
                shotname=sprintf('%s%sevent%d_%d.jpg',Parameters.screenshotdir, fileprefix,doevent,screenshotname_count);
                fid = fopen(shotname,'r');
                screenshotname_count = screenshotname_count +1;
                if(fid==1)
                    fclose(fid);
                end
            end
            imwrite(imagearray,shotname,'JPEG');
            Events.screenshotname{doevent} = shotname;
            if(Parameters.eyetracking)
                %add a message for the eyetracker with
                %the name of the jpg file
            end
            ScreenshotQueued = 0;
        end
        redrawflag = 0;
    end
    
    
    %determine if a flip is due
    flipnowtime = GetSecs;
  
        remainingtime = rem(flipnowtime-lastfliptime,Parameters.fliptime);
        if((Parameters.fliptime - remainingtime) < Flipreadytime)   %this flag will be set to 1 if we are near next flip cycle
            Flipready = 1;
        end
    
    if(flipneeded)% & Flipready )
        if(speedoptimizedmode)
            speedfliptime = Inf;
            speedeventsshown = 1;
        end
        
        Flipready = 0;
       
       [a,b,c] =  Screen('Flip', Parameters.window,time_to_flip);%,0,0,Parameters.sync);      %DISPLAY THE EVENT
       time_to_flip = 0;
       postflip = b;  %get the time stamp for after having flipped
        speedeventfinished = 1;    % we have drawn the current set of stimuli... only used for speed optimization
        lastfliptime = postflip;
        
        Events.timeflipped(find(Events.timeflipped == 999)) = postflip-starttime;     %at what time was the Stimuli actually made visible
        flipneeded = 0;
        
        if(Firstdrawevent> 0)
            % if our event was a little bit late, push everyone else's events backwards to compensate
            thattime = Events.timeused(Firstdrawevent);
            for(checkevent = 1:numevents)
                if(Events.timeused(checkevent) >  thattime)
                    Events.timeused(checkevent) =  Events.timeused(checkevent) + postflip - Events.timeused(Firstdrawevent);
                end
            end
            Firstdrawevent= 0;
        end
        if(Moviestarttime ==-99)
            Moviestarttime = postflip;
        end
        if(Movieplaying)
            Movietimepoints{Movieevent}(Movieframecounter) = postflip-Moviestarttime;
        end
    end
    
    
    
    %%%%%%%%%%%%%
    %Initiate a new audio playback
    if(Audiostartneeded)
        Audiostartneeded = 0;
        PsychPortAudio('Start', Parameters.pahandle );
        Audiostarttime = GetSecs;
        Events.timeflipped(audioevent) = Audiostarttime-starttime;
        Events.timepasted(audioevent) = Audiostarttime-starttime;
    end
    
    %%%%%%%%%%%%%
    %reset the soundwait if audio playback has stopped
    
    if(soundwait==1 & flipnowtime > Audiostarttime+ .1)  %wait until 50 milliseconds after audiostart to give it time to have kicked on
        status = PsychPortAudio('GetStatus',Parameters.pahandle);
        if status.Active == 0
            soundwait = 0;
            eventstodelay = find(Events.timeused > Events.timeused(audioevent));
            Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(audioevent);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
        end
    end
    
    if(markersend)   % a marker is waiting to be sent out the parallelport
        sendmarker(Parameters,markersend);
        %next, we set the time stamp of the corresponding event,
        % (only if it wasn't a keypress, those have no scheduled events associated with them)
        if(markersend ~=Parameters.MARKERS.INTRIALVALIDKEYRESPONSE & markersend ~=Parameters.MARKERS.INTRIALINVALIDKEYRESPONSE& markersend ~=Parameters.MARKERS.INTRIALUNEXPECTEDKEYRESPONSE & markersend~=Parameters.MARKERS.DINRESPONSE)
            Events.timeflipped(markerevent) = GetSecs-starttime;   %set the time flag for when this marker was actually sent
        end
        zeromarkertime =   GetSecs+ .025;     %set this marker back to zero 25 milliseconds in the future
        markersend = 0;                  %and zero out the markerflag
    end
    
    if(nowtime >  zeromarkertime & markeronline)  %the time has passed, set the parallel port back to zero, we're done with this marker
        sendmarker(Parameters,0);
        markeronline = 0;
        markerreset = GetSecs + .025;
    end
    
    
    %%%%%%%%%%%%%
    %Check the status of the mouse
    
    newbutton = 0;
    if(Parameters.mouse.enabled)    %check to see if the mouse has moved.  If so, update the position and store the data if we need to
        [Mousedatax,Mousedatay,buttons] = GetMouse(Parameters.window);
        if(buttons(1) ==0)
            button1wasdown = 0;
        end
        if(buttons(1)==1 & button1wasdown==0)
            newbutton = 1;
            button1wasdown = 1;
        end
    end
    
    
    %%%%%%%%%%%%%
    %Check the status of the keyboard
    
    [keyIsDown, keyTime, keyCode ] = KbCheck(-1);
    keydifference = keyCode - lastkeyCode;
    
    %%%%%%%%%%
    %Casual Keystrokes
    if(responsekey ==0 )   %record casual keystrokes
        if(max(keydifference) ==1)
            newkey = find(keydifference ==1);
            response  =  newkey(1);
            numkeypresses = numkeypresses + 1;
            Events.keypresses(numkeypresses) = response;
            Events.keypresstimes(numkeypresses) = keyTime-starttime;
            if(Parameters.invalidkeys_ParallelPortmark)
                
                Extratriggers =  [Extratriggers Parameters.MARKERS.INTRIALUNEXPECTEDKEYRESPONSE];  %add a new trigger to the list of events to send out the parallel port
            end
        end
        lastkeyCode = keyCode;
    end
    
    %%%%%%%%%%
    %Reaction time responses
    
    if(responsekey & GetSecs > responsebegin) %we are waiting for a keyboard response
        %So check to see if there is keyboard input
        
        if(GetSecs > responseend)   %abandon this response if it has gotten too old
            responsekey = 0;
            responseendproductlength =1;   % delete one if there's still room to delete
            responseendproduct =0;
        end
        
        if(max(keydifference) ==1)  %has a new key been pressed?
            newkey = find(keydifference ==1);  %which one?
            response  =  newkey(1);  %find the first of the new keys
            responsekeystrokeslength = responsekeystrokeslength + 1;
            responsetimestamps(responsekeystrokeslength) = keyTime - responsestarttime;
            responsekeystrokes(responsekeystrokeslength) = response;
            validchar = 0;
            
            %is this an acceptable keystroke?  If so, add it to the current
            %endproduct
            
            if((max(response ==responsekeys) | (responsekeys  == 0 & response > 0))  & responseendproductlength < responsemaxlength)  %valid character
                %convert keycodes to on-screen responses;
%                 response
%                 Events.choice = response;
%                 save('choice','choice');
                if(response == KbName('Space'))
                    charname = ' ';
                elseif(response == KbName(enterkey))
                    charname = 0;
                else
                    charname = KbName(response);
                    charname = charname(1);
                    if (responseuppercase)
                        if(charname >= 'a' & charname <= 'z')
                            charname = charname -32;
                        end
                    end
                end
                
                for(rc = 1:size(responseconversion,1))
                    if(response == responseconversion{rc,1})
                        charname = responseconversion{rc,2};
                    end
                end
                
                
                responseendproduct(responseendproductlength+1:responseendproductlength+length(charname)) = charname;  %add the new keystroke
                
                responseendproductlength =responseendproductlength+length(charname);
                
                Extratriggers =  [Extratriggers Parameters.MARKERS.INTRIALVALIDKEYRESPONSE];%add a new trigger to the list of events to send out the parallel port
                if(responseshowinput)
                    redrawflag = 1;
                    Flipready = 1;
                    flipneeded = 1;
                end
                if(responsewaitforenter == 0 & responseendproductlength >= responsemaxlength)  %hit the lenght limit, end it if we are not waiting for enter
                    responsekey = 0;
                end
                
                %allowbackspace
                if (response == KbName('Delete') | response == backkey) & responseallowbackspace   %backspace...
                    validchar = 1;
                    if( responseendproductlength >0)
                        responseendproductlength = responseendproductlength -1;   % delete one if there's still room to delete
                        responseendproduct = responseendproduct(1:responseendproductlength);
                        if(responseshowinput)
                            redrawflag = 1;
                            Flipready = 1;
                            flipneeded = 1;
                        end
                    end
                    % if Enter was pressed, complete the response if we're
                    % above the length
                end
                
                %update dynamic variables according to key clicks
                somethingchanged = 0;
                for(varnum = 1: length(Events.variableNames))
                    varmatch = intersect(Events.variableInput{varnum}, responseevent);  %which variables have output events that are active
                   if(length(varmatch) > 0)
                    for(evnum = varmatch)
                        varindex = find(Events.variableInput{varnum} ==  evnum);
                        mapping = Events.variableInputMapping{varnum}{varindex};
                        whichrow = find(mapping(:,1) ==response);
                        if(length(mapping(whichrow,2)) > 0)
                            Events.variableVal{varnum} = Events.variableVal{varnum} + mapping(whichrow,2);
                        end
                        somethingchanged = 1;
                    end
                   end
                end
                if(somethingchanged)
                    redrawflag = 1;
                    flipneeded = 1;
                    variablesUpdated = 1;
                end
                
            end
            %%%%%%%%%%%%%%%%%%
            %allowbackspace without any allowedchars
            if (response == KbName('Delete') | response == backkey) & responseallowbackspace   %backspace...
                validchar = 1;
                if( responseendproductlength >0)
                    responseendproductlength = responseendproductlength -1;   % delete one if there's still room to delete
                    responseendproduct = responseendproduct(1:responseendproductlength);
                    if(responseshowinput)
                        redrawflag = 1;
                        Flipready = 1;
                        flipneeded = 1;
                    end
                end
                % if Enter was pressed, complete the response if we're
                % above the length
            end
            %%%%%%%%%%%%%%%%%%%
            if(max(response == KbName('Return'))  &  responseendproductlength  >= responseminlength & responsewaitforenter ==1)
                responsekey = 0;
                if(responseshowinput)
                    redrawflag = 1;
                    Flipready = 1;
                    flipneeded = 1;
                end
            end
            if (validchar)
                Extratriggers =  [Extratriggers Parameters.MARKERS.INTRIALINVALIDKEYRESPONSE];%add a new trigger to the list of events to send out the parallel port
            end
        end
        if(responsekey ==0)   %this response is over
            responseend = 0;
            Events.response{responseevent} = responseendproduct;
            Events.responsert{responseevent} = responsetimestamps(end);
            responsekeyopen = 0;
            if(responsepausetime)
                eventstodelay = find(Events.timeused > Events.timeused(responseevent));
                Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(responseevent);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
                responsepausetime = 0;
            end
            Events.keystrokes{responseevent} = responsekeystrokes;
            Events.keystrokestime{responseevent} = responsetimestamps;
            Events.timeflipped(responseevent) = GetSecs-starttime;
            if (responseclearscreen)
                redrawflag = 1;
                flipneeded = 1;
                ThisBatchofEvents = [];
                currentvarnum = 0;
            end
            
            if(responseendtrial)
                alldone = 1;
                eventstodelay = find(Events.timeused > Events.timeused(responseevent));
                
                Events.timeused(eventstodelay ) = GetSecs-starttime;
                Events.timequeued(eventstodelay ) = GetSecs-starttime;
                Events.timepasted(eventstodelay ) = GetSecs-starttime;
                Events.timeflipped(eventstodelay ) = GetSecs-starttime;
                PsychPortAudio('Stop',Parameters.pahandle);
            end
            
        end
        lastkeyCode = keyCode;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Mouse Responses
    if(responsemouse && GetSecs > responsebegin_mouse)     %we are waiting for a mouse button response                                                         %response_mouse_spot = [x y dist];
        if(response_mouse_window_mintime > 0)  % do we need to keep track of time within each mouse window
            inwindow = 0;
            for multiplebuttons = 1:length(response_mouse_windows)  %go through the buttons
                [b,n]=size(response_mouse_windows{multiplebuttons});
                
                if n ==3 %button specified as a circle
                    distance = sqrt((theX-response_mouse_windows{multiplebuttons}(1))^2 +(theY-response_mouse_windows{multiplebuttons}(2))^2);
                    if(distance < response_mouse_windows{multiplebuttons}(3))
                        inwindow = multiplebuttons;
                    end
                elseif n ==4   %button specified as a rectangle
                    if( response_mouse_windows{multiplebuttons}(1)<=theX & response_mouse_windows{multiplebuttons}(2)<=theY & response_mouse_windows{multiplebuttons}(3)>=theX  & response_mouse_windows{multiplebuttons}(4)>=theY )
                        inwindow = multiplebuttons;
                    end
                end
            end
            
            if(inwindow == 0)
                response_mouse_window_counters  = zeros(length(response_mouse_window_counters),1)+999999;  %reset them all
            else
                if(response_mouse_window_counters(inwindow) ==  999999)  %new entry into this window)
                    response_mouse_window_counters  = zeros(length(response_mouse_window_counters),1)+999999;  %reset them all
                    response_mouse_window_counters(inwindow) = GetSecs;
                    
                end
            end
        end
        
        
        if(newbutton) %the left mouse button has been pressed
            ProperMouseClick=0;
             if(length(response_mouse_windows)> 0)
           
            for multiplebuttons = 1:length(response_mouse_windows)  %go through the buttons
                [b,n]=size(response_mouse_windows{multiplebuttons});
                
                if n ==3 %button specified as a circle
                    distance = sqrt((theX-response_mouse_windows{multiplebuttons}(1))^2 +(theY-response_mouse_windows{multiplebuttons}(2))^2);
                    if(distance < response_mouse_windows{multiplebuttons}(3))
                        ProperMouseClick=1;
                        windowclicked = multiplebuttons;
                    end
                    
                elseif n ==4   %button specified as a rectangle
                    if( response_mouse_windows{multiplebuttons}(1)<=theX & response_mouse_windows{multiplebuttons}(2)<=theY & response_mouse_windows{multiplebuttons}(3)>=theX  & response_mouse_windows{multiplebuttons}(4)>=theY )
                        ProperMouseClick=1;
                        windowclicked = multiplebuttons;
                    end
                else %no buttons specified
                    ProperMouseClick=1;
                    windowclicked = 0;
                end
            end
             else
                   ProperMouseClick=1;
                    windowclicked = 1;
             end
            if (ProperMouseClick==1 & ( GetSecs-response_mouse_window_counters(windowclicked) > response_mouse_window_mintime ||response_mouse_window_mintime ==0))
                responsemouse = 0;
                Events.timeflipped(response_mouse_event) = GetSecs-starttime;
                Events.mouse_response{response_mouse_event} = [theX theY];   %put the response in the appropriate variable.
                Events.mouse_rt(response_mouse_event) = GetSecs - response_mouse_starttime;
                Events.windowclicked{response_mouse_event} = windowclicked;
                
                if(mouse_responsepausetime)
                    eventstodelay = find(Events.timeused > Events.timeused(response_mouse_event));
                    Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(response_mouse_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
                    mouse_responsepausetime = 0;
                end
                if (responseclearscreen_mouse)
                    redrawflag = 1;
                    flipneeded = 1;
                    ThisBatchofEvents = [];
                    currentvarnum = 0;
                end
                
                %update dynamic variables according to mouse clicks
                for(varnum = 1: length(Events.variableNames))
                    varmatch = intersect(Events.variableInput{varnum}, response_mouse_event);  %which variables have output events that are active
                   if(length(varmatch) > 0)
                    for(evnum = varmatch)
                        varindex = find(Events.variableInput{varnum} ==  evnum);
                        mapping = Events.variableInputMapping{varnum}{varindex};
                        if(isfield(Events,'windowclicked'))
                            if(Events.windowclicked{response_mouse_event} > 0)
                                
                                whichrow = find(mapping(:,1) ==Events.windowclicked{response_mouse_event});
                                Events.variableVal{varnum} = mapping(whichrow,2);
                            end
                        end
                        redrawflag = 1;
                        flipneeded = 1;
                        variablesUpdated = 1;
                    end
                   end
                end
                
            else
                num_mouse_errors = num_mouse_errors+1;
                Events.mouse_errors{response_mouse_event}{num_mouse_errors} = [theX theY];
                Events.mouse_errorRTs{response_mouse_event}(num_mouse_errors) = GetSecs - response_mouse_starttime;
            end
            
            
            
            
        end
        %abandon this response if it has gotten too old
        if(GetSecs > response_mouse_end || Parameters.disableinput ==1)
            
            responsemouse = 0;
            response_mouse_end = 0;
            mouse_responsepausetime = 0;
            Events.mouse_response{response_mouse_event} = [-1 -1];
            Events.mouse_rt(response_mouse_event) =-1;
            if(mouse_responsepausetime)
                eventstodelay = find(Events.timeused > Events.timeused(response_mouse_event));
                Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(response_mouse_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
                mouse_responsepausetime = 0;
            end
        end
    end
    
    if(Parameters.mouse.enabled)    %check to see if the mouse has moved.  If so, update the position and store the data if we need to
        if(Mousedatax ~= theX | Mousedatay ~= theY)
            theY = Mousedatay; theX=Mousedatax;
            if(Parameters.mouse.datastore)
                mousecounter = mousecounter + 1;
                Mousedata.Time(mousecounter) = GetSecs();
                Mousedata.X(mousecounter) = Mousedatax;
                Mousedata.Y(mousecounter) = Mousedatay;
                Mousedata.button1(mousecounter) = buttons(1);
                Mousedata.button2(mousecounter) = buttons(2);
            end
            if(cursorsize > 0)
                redrawflag = 1;
                flipneeded = 1;
            end
        end
        
        if(Parameters.mouse.datastore & newbutton)
            mouseclicks = mouseclicks + 1;
            Mousedata.clicks(mouseclicks,1) = GetSecs();
            Mousedata.clicks(mouseclicks,2) = Mousedatax;
            Mousedata.clicks(mouseclicks,3) = Mousedatay;
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %     if(responseeye & Parameters.eyetracking & Parameters.eyerealtime)   %we are waiting for an eye movement                                                      %response_eye_spot = [x y dist];
    %         distance = sqrt((eyeX-response_eye_spot(1))^2 +(eyeY-response_eye_spot(2))^2);
    %         if(distance < response_eye_spot(3))
    %             responseeye = 0;
    %             Events.eye_response{response_eye_event} = [eyeX eyeY];   %put the response in the appropriate variable.
    %             Events.eye_rt(response_eye_event) = GetSecs - response_eye_starttime;
    %             if(Events.eye_rt(response_eye_event) > response_eye_nag & response_eye_nag>0)           %if they were too slow, nag them about being faster
    %                 briefmessage(Parameters,'Please try to respond faster','','Kartika',32,0,0,.4);
    %             end
    %
    %             eventstodelay = find(Events.timeused > Events.timeused(response_mouse_event));
    %
    %             Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(response_eye_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
    %             Events.timeflipped(response_eye_event) = GetSecs-starttime;
    %
    %         end
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(responseeye & Parameters.eyetracking & Parameters.eyerealtime)   %we are waiting for an eye movement                                                      %response_eye_spot = [x y dist];
        if(response_eye_window_mintime > 0)  % do we need to keep track of time within each mouse window
            inwindow = 0;
            for multiplebuttons = 1:length(response_eye_windows)  %go through the buttons
                [b,n]=size(response_eye_windows{multiplebuttons});
                
                if n ==3 %button specified as a circle
                    distance = sqrt((eyeX-response_eye_windows{multiplebuttons}(1))^2 +(eyeY-response_eye_windows{multiplebuttons}(2))^2);
                    if(distance < response_eye_windows{multiplebuttons}(3))
                        inwindow = multiplebuttons;
                    end
                elseif n ==4   %button specified as a rectangle
                    if( response_eye_windows{multiplebuttons}(1)<=eyeX & response_eye_windows{multiplebuttons}(2)<=eyeY & response_eye_windows{multiplebuttons}(3)>=eyeX  & response_eye_windows{multiplebuttons}(4)>=eyeY )
                        inwindow = multiplebuttons;
                    end
                end
            end
            
            if(inwindow == 0)
                response_eye_window_counters  = zeros(length(response_eye_window_counters),1)+999999;  %reset them all
            else
                if(response_eye_window_counters(inwindow) ==  999999)  %new entry into this window)
                    response_eye_window_counters  = zeros(length(response_eye_window_counters),1)+999999;  %reset them all
                    response_eye_window_counters(inwindow) = GetSecs;
                    
                end
            end
        end
        ProperGaze=0;
        
        for multiplebuttons = 1:length(response_eye_windows)  %go through the buttons
            [b,n]=size(response_eye_windows{multiplebuttons});
            
            if n ==3 %button specified as a circle
                
                distance = sqrt((eyeX-response_eye_windows{multiplebuttons}(1))^2 +(eyeY-response_eye_windows{multiplebuttons}(2))^2);
                if(distance < response_eye_windows{multiplebuttons}(3))
                    ProperGaze=1;
                    
                    windoweye = multiplebuttons;
                    
                end
            elseif n ==4   %button specified as a rectangle
                if( response_eye_windows{multiplebuttons}(1)<=eyeX & response_eye_windows{multiplebuttons}(2)<=eyeY & response_eye_windows{multiplebuttons}(3)>=eyeX  & response_eye_windows{multiplebuttons}(4)>=eyeY )
                    ProperGaze=1;
                    windoweye = multiplebuttons;
                end
                
            end
        end
        %             if(response_eye_window_mintime > 0)  % do we need to keep track of time within each mouse window
        %                 if(windoweye == 0)
        %                     response_eye_window_counters  = zeros(length(response_eye_window_counters),1)+999999;  %reset them all
        %                 else
        %                     if(response_eye_window_counters(inwindow) ==  999999)  %new entry into this window)
        %                         response_eye_window_counters  = zeros(length(response_eye_window_counters),1)+999999;  %reset them all
        %                         response_eye_window_counters(inwindow) = GetSecs;
        %
        %                     end
        %                 end
        %             end
        
        if (ProperGaze==1 & (GetSecs-response_eye_window_counters(windoweye) > response_eye_window_mintime ||response_eye_window_mintime ==0))
            
            responseeye = 0;
            Events.timeflipped(response_eye_event) = GetSecs-starttime;
            Events.eye_response{response_eye_event} = [eyeX eyeY];   %put the response in the appropriate variable.
            Events.eye_rt(response_eye_event) = GetSecs - response_eye_starttime;
            Events.eyewindow{response_eye_event} = windoweye;
            %%windowclicked
            
            if(eye_responsepausetime)
                eventstodelay = find(Events.timeused > Events.timeused(response_eye_event));
                Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(response_eye_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
                eye_responsepausetime = 0;
            end
            if (responseclearscreen_eye)
                redrawflag = 1;
                flipneeded = 1;
                ThisBatchofEvents = [];
                currentvarnum = 0;
            end
            
            %update dynamic variables according to mouse clicks
            for(varnum = 1: length(Events.variableNames))
                varmatch = intersect(Events.variableInput{varnum}, response_eye_event);  %which variables have output events that are active
                for(evnum = varmatch)
                    varindex = find(Events.variableInput{varnum} ==  evnum);
                    mapping = Events.variableInputMapping{varnum}{varindex};
                    if(isfield(Events,'eyewindow'))
                        if(Events.eyewindow{response_eye_event} > 0)
                            whichrow = find(mapping(:,1) ==Events.eyewindow{response_eye_event});
                            Events.variableVal{varnum} = mapping(whichrow,2);
                        end
                    end
                    redrawflag = 1;
                    flipneeded = 1;
                    variablesUpdated = 1;
                end
                
            end
            
            
            %abandon this response if it has gotten too old
            if(GetSecs > response_eye_end || Parameters.disableinput ==1)
                
                responseeye = 0;
                response_eye_end = 0;
                mouse_responsepausetime = 0;
                Events.eye_response{response_eye_event} = [-1 -1];
                Events.eye_rt(response_eye_event) =-1;
                if(eye_responsepausetime)
                    eventstodelay = find(Events.timeused > Events.timeused(response_eye_event));
                    Events.timeused(eventstodelay) = Events.timeused(eventstodelay) + GetSecs-Events.timeused(response_eye_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
                    eye_responsepausetime = 0;
                end
            end
        end
    end
    
    if(Parameters.eyetracking & Parameters.eyerealtime)
        
        [keyIsDown, keyTime, keyCode2 ] = KbCheck(-1);
        eyeKey = KbName('F1');
        if(keyCode2(eyeKey) && Parameters.eyecursor ==2)
            useCursor = 1;
        elseif(Parameters.eyecursor ==1)
            useCursor = 1;
        else
            useCursor = 0;
        end
        
        if(useCursor ==0 & lastuseCursor == 1)
            redrawflag = 1;
        end
        lastuseCursor = useCursor;
        
        
        if(Parameters.Eyelink)
            if Eyelink('NewFloatSampleAvailable') > 0
                %get the sample in the form of an event structure
                evt = Eyelink('NewestFloatSample');
                %if we do, get current gaze position from sample
                eyeX = evt.gx(eye_used+1);
                eyeY = evt.gy(eye_used+1);
                if(Parameters.eyedatastore)
                    eyedatacounter = eyedatacounter + 1;
                    Eyedata.X(eyedatacounter)  =  eyeX;
                    Eyedata.Y(eyedatacounter)  =  eyeY;
                    Eyedata.Time(eyedatacounter) = GetSecs();
                end
                
                if(useCursor)
                    if(abs(eyeX-oldeyeX)>Parameters.eyecursorthreshold |abs(eyeY -oldeyeY)>Parameters.eyecursorthreshold)
                        flipneeded = 1;
                        redrawflag = 1;
                    end
                end
                
                oldeyeX = eyeX;
                oldeyeY = eyeY;
                
                
            end
        end
        if(Parameters.TobiiX2)
            [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
            if(length(lefteye) > 7)
                leftvalid = lefteye(13);
                rightvalid = righteye(13);
                eyeX  =  lefteye(7)*Parameters.centerx*2;  %assume the left eye is valid by default
                eyeY  =  lefteye(8)*Parameters.centery*2;
                eyeXR = righteye(7)*Parameters.centerx*2;
                eyeYR = righteye(8)*Parameters.centery*2;
                if(leftvalid == 0 & rightvalid == 0)  %both eyes are valid, average them together
                    eyeX = (eyeX + eyeXR) /2;
                    eyeY = (eyeY + eyeYR) /2;
                end
                if(leftvalid > 0 & rightvalid ==0)  %just the right eye is valid
                    eyeX = eyeXR;
                    eyeY = eyeYR;
                end
                if(leftvalid > 0 & rightvalid >0)  %no eyes are valid
                    eyeX = 0;
                    eyeY = 0;
                end
                
                if(abs(eyeX- oldeyeX) + abs(eyeY- oldeyeY) > 0)  %did the eye position move?
                    if(useCursor)
                        if(abs(eyeX-oldeyeX)>Parameters.eyecursorthreshold |abs(eyeY -oldeyeY)>Parameters.eyecursorthreshold)
                            flipneeded = 1;
                            redrawflag = 1;
                        end
                    end
                    
                    oldeyeX = eyeX;
                    oldeyeY = eyeY;
                    if(Parameters.eyedatastore)
                        eyedatacounter = eyedatacounter + 1;
                        Eyedata.X(eyedatacounter)  =  eyeX;
                        Eyedata.Y(eyedatacounter)  =  eyeY;
                        Eyedata.Time(eyedatacounter) = GetSecs();
                    end
                end
            end
        end
        
    end
    if(response_DIN_event > 0)
        
        
        Datapixx('RegWrRd');
        values = dec2bin(Datapixx('GetDinValues'));
        
        
        if(values(response_DIN_pin1) ==response_DIN_value)
            Events.mouse_response(response_DIN_event)  = 1;
        end
        if(values(response_DIN_pin2) ==response_DIN_value)
            Events.mouse_response(response_DIN_event)  = 2;
        end
        if(Events.mouse_response(response_DIN_event) > 0)
            Events.timeused(response_DIN_event+1:numevents) = Events.timeused(response_DIN_event+1:numevents) + GetSecs-Events.timeused(response_DIN_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
            Events.mouse_rt(response_DIN_event) = GetSecs - response_DIN_starttime;
            response_DIN_event = 0;
            Extratriggers =  [Extratriggers Parameters.MARKERS.DINRESPONSE];
            
        end
        if( GetSecs> response_DIN_end )
            Events.timeused(response_DIN_event+1:numevents) = Events.timeused(response_DIN_event+1:numevents) + GetSecs-Events.timeused(response_DIN_event);   % bump the timing down the line to ensure each stimulus is presented for at least its designated duration
            Events.mouse_response(response_DIN_event)  = -1;
            Events.mouse_rt(response_DIN_event) = -1;
            response_DIN_event = 0;
        end
        
    end
end



%DONE!  The trial is over.

if(Parameters.eyetracking)
    if(Parameters.Eyelink)
        difference = round((GetSecs-starttime)*1000);
        Eyelink('Message', sprintf('Recording ended Time (msec) %d',difference));
        Eyelink('StopRecording');
    end
    if(Parameters.eyerealtime & Parameters.eyedatastore)
        Events.Eyedata = Eyedata;
    end
    if(Parameters.TobiiX2)
        
        tetio_stopTracking;
    end
    
end

if(  resetDatapixxDin  > 0 & flipnowtime- resetDatapixxDin  > .05)
    Datapixx('SetDinDataOut',0)
    Datapixx('RegWrRd')
    resetDatapixxDin = 0;
    
end


if (responsekeyopen)
    Events.response{responsekeyopen} =0;
    Events.responsert{responsekeyopen} = 0;
end


Events.Movietimepoints = Movietimepoints;

Events.timeused = Events.timeused - starttime;   %revert the timing schedule to a 0 start
Events.starttime = starttime;   %what was the initial time of the trial (needed to compute RTs)

if(Parameters.mouse.enabled)
    if(Parameters.mouse.datastore)
        Events.Mousedata = Mousedata;
    end
end



Priority(0);
end