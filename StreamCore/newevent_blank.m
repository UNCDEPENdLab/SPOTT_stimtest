function [Events evnum] = newevent_blank(Events,time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_blank(Events,time)
% An Event that will blank the screen. 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment when screen is blanked
%
%newevent_blank is called by your block files.



if(length(Events) == 0);
    evnum = 1;
else
    evnum = length(Events.itemnum)+1;
end

Events.itemset(evnum) = 0;  
Events.itemnum(evnum) = 0;
Events.location(1,evnum) = 0;
Events.location(2,evnum) = 0;
Events.time(evnum) = time;
Events.action(evnum) = 7;

   
Events.screenshot(evnum) = 0;

Events.misc1(evnum) = 0;

end
