function stimstruct = CreateStimStruct(structtype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CreateStimStruct
% CreateStimStruct will create different stimului with a set of properties
% that can be presented in a block file.
%
%CreateStimStruct is called by your block files.

    % Give numeric value type from semantic value type
    switch(structtype)
        case 'image'
            stimstruct.type = 1;
        case 'text'
            stimstruct.type = 2;
        case 'shape'
            stimstruct.type = 3;
        case 'movie'
            stimstruct.type = 4;
        case 'audio'
            stimstruct.type = 5;
        case 'imagefont'
            stimstruct.type = 6;
        case 'gabor'
            stimstruct.type = 7;
%         case 'colorwheel'
%             stimstruct.type = 8;
    end
    
    
    % STEP 1: Initialize structure and set variable defaults
    % Generic variables:
    stimstruct.stimuli = []; % set the stimuli list
    stimstruct.stimsize = 1.0; % set the size scaling 
    stimstruct.color = [0,0,0]; % set the color 
    stimstruct.xdim = [0]; %horizontal width in pixels
    stimstruct.ydim = [0];% vertical height in pixels
    stimstruct.savestim = 0; %save the stimulus? 0 = no; 1 = yes 
    stimstruct.pixcount = []; %
   
    % Image variables:
    stimstruct.bottomjustify = 0;  %will place stimulus using bottom boundary instead of center, 0 = no; 1 = yes 
    stimstruct.leftjustify = 0; %will place stimulus using left boundary instead of center, 0 = no; 1 = yes 
    stimstruct.rotate = 0; %Set the angle of which you want the stimulus rotated
    stimstruct.clippingboundary = -1; % set the texture clipping boundary
    stimstruct.transparencythreshold = -1; % set the transparency value
    stimstruct.pointer = []; %
   
    % imagefont variables:
    stimstruct.basename = 'And'; %Set the basename of your imagefont stimulus files
    stimstruct.basename_suffix = '.png'; %set the asename suffix for your imagefont stimulus files
    
    % Text variables:
    stimstruct.font = {'Arial'}; %Set the font of the text stimulus
    stimstruct.wrapat = 999;  %word wrap at this number of characters
    stimstruct.vSpacing = 1.25;  %Line spacing for word wrap
    
    % Shape variables: lines
    stimstruct.linelength = [50]; %set the length of the line stimulus
    stimstruct.linewidth = [3]; %set the width of the line stimulus
    stimstruct.lineangle = [0]; %set the andle of the line stimulus
   
    % Shape variables: polygons
    stimstruct.pointlist = {[1,1]}; %set the vertices of the FillPoly or FramePoly stimulus
   
    % Audio variables:
    stimstruct.volume = [1]; %Set the volume of the auditory stimulus 
    stimstruct.monoaudio = 'd'; %Set the mono output of the auditory stimulus
    stimstruct.audiowait = 0;  %should other events wait for audio to finish? 0 = no; 1 = yes 
    
    % Gabor variables
    stimstruct.norm_freq = 0.1; %set the frequency of the gabor
    stimstruct.orient_deg = 0; % set the degrees of orientation of the gabor
    stimstruct.phase = 0; %set the phase of the gabor
    stimstruct.bg_contrast = 127; %set the contrast of the background of the gabor 0 = black, 255 = white
    stimstruct.sigma = 1; %set the sigma value of the gabor
    stimstruct.contrast = 1; % set the contrast value of the gabor, scalar
    stimstruct.window = {'gauss'};%
   
    % Color wheel variables:
    stimstruct.radius = 350;

    
    % STEP 2: Set variable defaults based on stimulus type
    switch(structtype)
        case 'text'
            stimstruct.stimsize = 30; % set default font size to 30
      end
    
end