function [Events,evnum] = newevent_keyboard(Events,time,responsestruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_keyboard(Events,time,responsestruct)
% Allows for the collection of a response using the keyboard. 
%
% Input
%    Events: Structure containing information about all Events presented
%    time: time relative to start of the experiment when response begins
%    responsestruct: references the specific responsestruct containing the
%    properties of this response
%
%newevent_keyboard is called by your block files.
% pressed_key = [];
% [keyIsDown,secs,keyCode]=KbCheck;
% if keyIsDown
%     if find(keyCode==1) == responsestruct.allowedchars(1) | find(keyCode==1) == responsestruct.allowedchars(2)
%     pressed_key = find(keyCode==1);
%     end
% %     sca
% %     keyboard
% end
% if keyIsDown & (keyCode == responsestruct.allowedchars(1) | keyCode == responsestruct.allowedchars(1))
% sca
% keyboard
% end
if(length(Events) == 0);
    evnum = 1;
else
    evnum = length(Events.itemnum)+1;
end

if(ischar(responsestruct.x))
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},responsestruct.x))
            varnum = i;
        end
    end
    Events.location(1,evnum) = -varnum;
else
    Events.location(1,evnum) = responsestruct.x;
end

if(ischar(responsestruct.y))
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},responsestruct.y))
            varnum = i;
        end
    end
    Events.location(2,evnum) = -varnum;
else
    Events.location(2,evnum) = responsestruct.y;
end

Events.itemset(evnum) = 0;       % This required but unnecessary to you
Events.itemnum(evnum) = 0;       % This required but unnecessary to you
Events.time(evnum) = time;
Events.action(evnum) = 2;

Events.screenshot(evnum) = 0;

Events.misc1(evnum) = 0;
Events.misc2{evnum} = 0;
Events.misc3(evnum) = 0;

Events.timeout(evnum) = responsestruct.timeout;
Events.mintime(evnum) = responsestruct.mintime;

Events.width(evnum) = responsestruct.width;
Events.allowedchars(evnum) =    {responsestruct.allowedchars};
Events.minlength(evnum) =     responsestruct.minlength;
Events.maxlength(evnum) =     responsestruct.maxlength;
Events.font{evnum} =     responsestruct.font{1};
Events.fontsize(evnum) =     responsestruct.fontsize;
Events.showinput(evnum) =    responsestruct.showinput;
Events.allowbackspace(evnum) =     responsestruct.allowbackspace;
Events.waitforenter(evnum) =     responsestruct.waitforenter;
Events.uppercase(evnum) =     responsestruct.uppercase;
Events.endtrial(evnum) =     responsestruct.endtrial;
Events.pausetime(evnum) =     responsestruct.pausetime;
Events.conversion{evnum} =     responsestruct.conversion;
Events.clearscreen(evnum) =     responsestruct.clearscreen;
Events.variableInputByEv(evnum) = 0;
Events.variableInputMappingByEv{evnum}  = [];

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

