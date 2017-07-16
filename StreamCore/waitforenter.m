%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%waitforenter
% This is a simple little script to wait for the enter key to be pressed.

s=1;
    while s;
        [ keyIsDown, seconds, keyCode ]=KBCheck;
        if(keyIsDown)
            keyCode;
            
        end

        if(keyCode(32)==1 | keyCode(44)==1| keyCode(40)==1)
            s=0;
        end
    end;
