function [Events evnum] = newevent_gaze(Events,time,responsestruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_gaze(Events,time,responsestruct)
% Allows for the collection of a mouse click response. 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment when response begins
%    responsestruct: references the specific responsestruct containing the
%    properties of this response
%
%newevent_gaze is called by your block files.

if(length(Events) == 0);
    evnum = 1;
else
    if (isfield(Events,'itemnum')) == 0
        evnum = 1;
    else
        evnum = length(Events.itemnum)+1;
    end
end


Events.itemset(evnum) = 0;       % This required but unnecessary to you
Events.itemnum(evnum) = 0;       % This required but unnecessary to you
Events.location(1,evnum) = 0;    % This required but unnecessary to you
Events.location(2,evnum) = 0;    % This required but unnecessary to you
Events.time(evnum) = time;
Events.action(evnum) = 6;
Events.screenshot(evnum) = 0;

Events.spatialwindows{evnum} = responsestruct.spatialwindows;
Events.spatialwindows_mintime{evnum} = responsestruct.spatialwindows_mintime;
Events.timeout(evnum) = responsestruct.timeout;
Events.mintime(evnum) = responsestruct.mintime;
Events.pausetime(evnum) = responsestruct.pausetime;
Events.clearscreen(evnum) = responsestruct.clearscreen;


Events.misc1(evnum) = 0;

Events.misc2{evnum} = {0};

Events.misc3(evnum) = 0;

%figure out if this input goes to any variable
if length(responsestruct.variableInputName)> 0
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},responsestruct.variableInputName))
            varnum = i;
        end
    end
    Events.variableInputByEv(evnum)  = varnum;%which variable
    Events.variableInputMappingByEv{evnum}  = responsestruct.variableInputMapping;

    
end

end