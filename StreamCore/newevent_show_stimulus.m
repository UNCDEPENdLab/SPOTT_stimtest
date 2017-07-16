function [Events evnum]= newevent_show_stimulus(Events,set,num,locx,locy,time,screenshot,eventclear)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%newevent_show_stimulus(Events,set,num,locx,locy,time,screenshot,misc1)
% Presents a stimulus on the screen during the experiment 
%
% Input
%    Events: Structure containing information about all Events presented
%    set: Stimulus set number
%    num: Stimulus number within the defined set
%    locx: X location stimulus will be presented
%    locy: Y location stimulus will be presented
%    time: time relative to start of the experiment stimulus will be presented
%    screenshot: Should Stream take a screenshot?
%    eventclear: Should Stream clear the screen prior to presenting this stimulus?
%
%newevent_show_stimulus is called by your block files.

if(length(Events) == 0);
    evnum = 1;
else
    if (isfield(Events,'itemnum')) == 0
        evnum = 1;
    else
    evnum = length(Events.itemnum)+1;
    end
end
%set up SetNum dynamic variable
if(ischar(set))
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},set))
            varnum = i;
        end
    end
Events.itemset(evnum) = -varnum;
else %Not using the dyn var
Events.itemset(evnum) = set;
end
%set up StimNum dynamic variable
if(ischar(num))
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},num))
            varnum = i;
        end
    end
Events.itemnum(evnum) = -varnum;
else%Not using the dyn var
Events.itemnum(evnum) = num;
end
%set up MouseX dynamic variable
if(ischar(locx))
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},locx))
            varnum = i;
        end
    end
Events.location(1,evnum) = -varnum;
else%Not using the dyn var
Events.location(1,evnum) = locx;
end

%set up MouseY dynamic variable
if(ischar(locy))
    for (i = 1:length(Events.variableNames))
        if(strcmp(Events.variableNames{i},locy))
            varnum = i;
        end
    end
Events.location(2,evnum) = -varnum;
else%Not using the dyn var
Events.location(2,evnum) = locy;
end



Events.time(evnum) = time;
Events.action(evnum) = 1;



%Screenshot yes/no
b=strcmp(screenshot,'screenshot_yes');
if b==0;
    b=strcmp(screenshot,'screenshot_no');
    if b==0;
        error('Error: Please check spelling of Screenshot variable in newevent_show_stimulus')
    else 
        b=0;
    end
end    
Events.screenshot(evnum) = b;
  
%Clear yes/no
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
