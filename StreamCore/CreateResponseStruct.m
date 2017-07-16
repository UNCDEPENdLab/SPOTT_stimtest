function responsestruct = CreateResponseStruct()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CreateResponseStruct
% CreateResponseStruct will specify a set of parameters for either a
% keyboard or a mouse click response. Responsestructs are necessary for
% response events. 
%
%CreateResponseStruct is called by your block files.


    % set default values
    responsestruct.showinput = 0; %allows participants to see their responses
    responsestruct.width = 50;
    responsestruct.allowedchars = 0; %set a list of acceptable characters to respond with
    responsestruct.conversion = {0,0}; %create custome responses
    responsestruct.minlength = 1; %Minimum length of response
    responsestruct.maxlength = 1; %maximum length of response
    responsestruct.font = {'Arial'}; %font response will appear in
    responsestruct.fontsize = 45; %size font will appear in
    
    responsestruct.x = 0; %location os response
    responsestruct.y = 0; 

    responsestruct.timeout = 0; %maximum time allotted for response   
    responsestruct.mintime  = 0; %minimum wait time before response time
    
    responsestruct.allowbackspace = 0; %allow participants to edit their responses using backspace or delete
    responsestruct.waitforenter = 0; %wait for participants to press the enter key to submit response
    responsestruct.uppercase = 0; %present the response in uppercase letters
    responsestruct.pausetime = 1; %pause all timing variables until response is given
    responsestruct.clearscreen = 0; %clear the screen after the response
    
    
    responsestruct.endtrial = 0; %immediately end the trial
   
    %Mouse or eye gaze
    responsestruct.spatialwindows = {[0]}; %create specific windows in which the mose response must be located
    responsestruct.spatialwindows_mintime = [0];
    
    
    %Dynamic variables
    responsestruct.variableInputName='';
    responsestruct.variableInputMapping=[];
   
    
    
    
end