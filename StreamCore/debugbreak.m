%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%debugbreak is a simple script used for debugging. debugbreak will exit out
%of Psychtoolbox and return the users control to the keyboard as well as
%bringing back the Windows taskbar if using a PC.

sca %break out of PTB
ListenChar(0); %turn off keyboard inup
ShowHideWinTaskbarMex(1); %bring back the windows task bar
keyboard %return uder's control to the keyboard