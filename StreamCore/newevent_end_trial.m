function [Events evnum] = newevent_end_trial(Events,time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_end_trial(Events,time)
% An event that will end the trial 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time of which the trial will end
%
%newevent_end_trial is called by your block files.

if(length(Events) == 0);
    evnum = 1;
else
    evnum = length(Events.itemnum)+1;
end

Events.action(evnum) = -1;
Events.time(evnum) = time;

Events.itemset(evnum) = 0;     % This required but unnecessary to you 
Events.itemnum(evnum) = 0;     % This required but unnecessary to you  
Events.location(1,evnum) = 0;  % This required but unnecessary to you 
Events.location(2,evnum) = 0;  % This required but unnecessary to you 
Events.screenshot(evnum) = 0;  % This required but unnecessary to you 

end
