function [Events evnum] = newevent_command(Events,time,command,eventclear)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_command(Events,time,command,misc1)
% Executes a defined command.  
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment stimulus will be presented
%    command: The MATLAB command to be executed
%    misc1: Should Stream clear the screen prior to presenting this stimulus?
%
%newevent_command is called by your block files.



if(length(Events) == 0);
    evnum = 1;
else
    evnum = length(Events.itemnum)+1;
end
Events.itemset(evnum) = 0;       % This required but unnecessary to you 
Events.itemnum(evnum) = 0;       % This required but unnecessary to you 
Events.location(1,evnum) = 0;    % This required but unnecessary to you  
Events.location(2,evnum) = 0;    % This required but unnecessary to you 
Events.time(evnum) = time;
Events.action(evnum) = 27;
Events.screenshot(evnum) = 0;


Events.command{evnum} = command;

c=strcmp(eventclear,'clear_no');  
if c==0;
    c=strcmp(eventclear,'clear_yes');
    if c==0;
        error('Error: Please check spelling of Clear variable in newevent_show_stimulus')
    else 
        c=0;
    end
end  
Events.eventclear(evnum) = c;

end