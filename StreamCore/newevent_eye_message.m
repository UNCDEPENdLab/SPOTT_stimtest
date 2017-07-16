function [Events evnum] = newevent_eye_message(Events,time,eye_message)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_eye_message(Events,time,misc2)
% Presents a message while eyetracking is active. 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment stimulus will be presented
%    misc2: The message being presented
%
%newevent_eye_message is called by your block files.

if(length(Events) == 0);
    evnum = 1;
else
    evnum = length(Events.itemnum)+1;
end

Events.itemset(evnum) = 0;      % This required but unnecessary to you 
Events.itemnum(evnum) = 0;      % This required but unnecessary to you 
Events.location(1,evnum) = 0;   % This required but unnecessary to you 
Events.location(2,evnum) = 0;   % This required but unnecessary to you  
Events.time(evnum) = time;
Events.action(evnum) = 5;

Events.screenshot(evnum) = 0;


Events.eye_message{evnum} = eye_message;

end