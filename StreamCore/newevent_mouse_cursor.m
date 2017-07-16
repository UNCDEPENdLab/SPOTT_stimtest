function [Events evnum] = newevent_mouse_cursor(Events,time,mousex,mousey,cursorsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_mouse_cursor(Events,time,mousex,mousey,cursorsize)
% Presents the mouse cursor on the screen. 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment stimulus will be presented
%    mousex: X location of where the cursor appears
%    mousey: Y location of where the cursor appears
%    cursorsize: Set the diameter of the cursor
%
%newevent_mouse_cursor is called by your block files.

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
Events.location(1,evnum) = 1;   % This required but unnecessary to you
Events.location(2,evnum) = 1;   % This required but unnecessary to you
Events.time(evnum) = time;
Events.action(evnum) = 8;
Events.screenshot(evnum) = 0;
Events.mousex(evnum) = mousex;
Events.mousey(evnum) = mousey;
Events.cursorsize(evnum) = cursorsize; %Determine the size of the cursor
end
