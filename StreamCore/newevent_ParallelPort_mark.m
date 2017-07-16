function [Events evnum] = newevent_ParallelPort_mark(Events,time,num)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_ParallelPort_mark(Events,time,num)
% Presents a stimulus on thye screen during the experiment 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment stimulus will be presented
%    num: Sets the value of the parallel port marker
%
%newevent_ParallelPort_mark is called by your block files.

if(length(Events) == 0);
    evnum = 1;
else
    evnum = length(Events.itemnum)+1;
end

Events.itemset(evnum) = 0;   % This required but unnecessary to you 
Events.itemnum(evnum) = num;
Events.location(1,evnum) = 0; % This required but unnecessary to you 
Events.location(2,evnum) = 0; % This required but unnecessary to you 
Events.time(evnum) = time;
Events.action(evnum) = 4;
Events.screenshot(evnum) = 0;

end
