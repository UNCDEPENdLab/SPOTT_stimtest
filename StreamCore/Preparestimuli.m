function Stimuli_set = Preparestimuli(Parameters,stimstruct,stimuli,font,stimsize,color,clippingboundary,transparencythreshold,savestim)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preparestimuli(Parameters,stimstruct,stimuli,font,stimsize,color,clippingboundary,transparencythreshold,savestim)
% Preparestimuli will create stimuli based on the set parameters of the
%stimstructs defined in the InitializeBlock section of the block file.
% Input
%    Parameters: Parameter set for this experiment (Setparameters.m)
%    stimstruct: defines the current stimstruct that is being checked for errors
%    stimuli: the number of the stimulus eing prepared
%    font: Stimulus property
%    stimsize: Stimulus property
%    color: Stimulus property
%    clippingboundary: Stimulus property
%    transparenctthreshold: Stimulus property
%    savestim: Stimulus property
%
%Preparestimuli calls:
%	CheckStimuli
%	Make_gabor
%	DrawFormattedTextBounds
%
%Preparestimuli is called by your block files when you create a stimstruct.

stimtype = stimstruct.type;

% check stimstruct with CheckStimuli.m
CheckStimuli(stimstruct);

%if stimuli are good:
stimuli = stimstruct.stimuli;


%stimtype  of 1
%   stimuli will be loaded as image files in to openGL textures


%stimtype of 2
%    stimuli will be drawn on the Screen during runtime with drawtext using
%    font and stimsize

%stimtype of 3
%Psychtoolbox shape

%stimtype of 4
%stimuli is a movie

%stimtype of 5
%stimuli is an auditory stimulus

%stimtype of 6
%stimuli is an imagefont

%stimtype of 7,
%stimuli is a gabor

%stimtype of 8,
%stimuli is a colorwheel (In progress)

% Other input parameters:
% stimuli:   List of stimuli, or image file names for textures
% font:       for Text stimuli, the name of the font
% stimsize:   for Text stimuli, the font size,  for Texture stimuli, a scaling factor
% color:       for Text stimuli, the RGB colors
% clippingboundary:   for Texture stimuli, the program will automatically trim away the transparent pixels around an image, and impose a clipping boundary of this many pixels on the bottom and right sides of the texture.  Set to -1 to disable
% transparencythreshold:  Pixels lighter than this value (on a scale of 1-255, where 255 is white) will be set to transparent.
%


% Returned value: Stimuli_set

%   .type:   1= texture, 2 = word, etc.
%   .stim{n}:    actual content,   cell array
%   .font{n}:    must match loadable font types
%   .stimsize:   font size for a font stimulus, scaling factor for a texture
%   .color(3,n): [RGB]
%   .xdim(n):    Horizontal pixels
%   .ydim(n):    Vertical pixels
%   .pointer:    pointer to the texture
%   .pixcount:   count of pixels that are not transparent  (double check)
%   .clippingboundary:        adjust spacing of stimuli by adding white space
%   .transparencythreshold:   set pixels of a certian value to transparent



errors = fopen('errorlog.txt','a');

% set variable placeholders
Stimuli_set.type = stimtype; % stimulus type
Stimuli_set.stimnames = {}; % list of stimuli
Stimuli_set.stimuli = [];
Stimuli_set.stimsize = [];
Stimuli_set.color = [];
Stimuli_set.xdim = [];
Stimuli_set.ydim = [];
Stimuli_set.bottomjustify = [];
Stimuli_set.leftjustify = [];
Stimuli_set.rotate = [];
Stimuli_set.clippingboundary = [];
Stimuli_set.transparencythreshold = [];
Stimuli_set.savestim = [];
% images
Stimuli_set.pixcount = [];
Stimuli_set.pointer = [];
% text
Stimuli_set.font = [];
Stimuli_set.wrapat = [];
Stimuli_set.vSpacing = [];
%imagefont
Stimuli_set.basename = [];
Stimuli_set.basename_suffix = [];
% lines
Stimuli_set.linelength = [];
Stimuli_set.linewidth = [];
Stimuli_set.lineangle = [];
% polygons
Stimuli_set.pointlist = {[1,1]};
% audio
Stimuli_set.volume = [];
Stimuli_set.monoaudio = [];
Stimuli_set.audiowait = [];
% gabor
Stimuli_set.norm_freq = [];
Stimuli_set.orient_deg = [];
Stimuli_set.phase = [];
Stimuli_set.bg_contrast = [];
Stimuli_set.sigma = [];
Stimuli_set.contrast = [];
Stimuli_set.window = [];
% color wheel
%Stimuli_set.radius = [];


Stimuli_set.savestim = stimstruct.savestim;


%Set up the progressbar here if enabled in Setparameters.m
if Parameters.Progressbarenabled == 1;
    done = Parameters.Progressbaritems_done;
end
esccode = KbName('ESCAPE');



% Prepare stimuli based on stimulus type
for(stim = 1:length(stimuli))
    [keyIsDown, keyTime, keyCode ] = KbCheck(-1);
    if(Parameters.interruptible & keyCode(esccode))   %if someone pressed escape during the previous trial, break us out of here
        sca %shutdown psychtoolbox
        error('User aborted');
        PsychPortAudio('Stop',Parameters.pahandle);
        
    end
    
    %Prepare the stimulus
    switch(stimtype)
        case 1     %this is a texture stimulus, which means we load it from an image file
            
            %Set these variables specified in the stimstruct:
            Stimuli_set.stimnames{stim} = stimuli{stim};  %filenames of the textures
            
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);   %if we've passed in multiple sstimsizes, assign one to each stimulus
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;         %otherwise there's just one stimsize assigned to each of them
            end
            
            try
                Stimuli_set.rotate(stim) = stimstruct.rotate(stim);
            catch
                Stimuli_set.rotate(stim) = stimstruct.rotate;
            end
            
            try
                Stimuli_set.leftjustify(stim) = stimstruct.leftjustify(stim);
            catch
                Stimuli_set.leftjustify(stim) = stimstruct.leftjustify;
            end
            
            try
                Stimuli_set.bottomjustify(stim) = stimstruct.bottomjustify(stim);
            catch
                Stimuli_set.bottomjustify(stim) = stimstruct.bottomjustify;
            end
            
            
            try
                Stimuli_set.clippingboundary(stim) = stimstruct.clippingboundary(stim);
                boundary = stimstruct.clippingboundary(stim);
            catch
                Stimuli_set.clippingboundary(stim) = stimstruct.clippingboundary;
                
                boundary = stimstruct.clippingboundary;
            end
            
            try
                Stimuli_set.transparencythreshold(stim) = stimstruct.transparencythreshold(stim);
                tthresh = stimstruct.transparencythreshold(stim);
            catch
                Stimuli_set.transparencythreshold(stim) = stimstruct.transparencythreshold;
                tthresh = stimstruct.transparencythreshold;
            end
            
            %set the filename of the texture file to be presented:
            s= sprintf('%s%s',Parameters.stimulidir,stimuli{stim});
            
            alph = 0;
            
            try
                [stimulus, map, alph] = imread(s);   %read in the stimulus for this array position
            catch
                
                sca;
                beep;
                StreamDebug = dbstack;
                ErrorFile = StreamDebug(2).file;
                ErrorLine = num2str(StreamDebug(2).line);
                %h = msgbox(stimcheck.errormsg, 'Stimulus Error', 'error');
                disp(' ');
                disp('**************************************************');
                disp('**************************************************');
                disp('**               Image File Error               **');
                disp('**************************************************');
                disp('**************************************************');
                disp(' ');
                disp(' ');
                disp('You have tried to load a texture file that is not');
                disp('present in the Stimulus folder of the Main Stream');
                disp('Directory. Please check your file name and try again.');
                tempstring = sprintf('This occurred on line %s in file %s',eval(ErrorLine),ErrorFile);
                disp(tempstring)
                disp('**************************************************');
                disp('**************************************************');
                disp('**************************************************');
                disp('**************************************************');
                disp(' ');
                ListenChar(1);
                
                try
                    if ispc
                        try
                            ShowHideFullWinTaskbarMex(1);
                        catch ME
                            ShowHideWinTaskbarMex(1);
                        end
                    end
                end
                keyboard;
            end
            
            
            if (Parameters.vpixx.M16==0 | Parameters.vpixx.enabled ==0)
                stimulus = double(stimulus);
            end
            
            if(size(map,1) >0)  %If this is a colormapped image, turn it into RGB
                stimulus2 = 0;
                for(x = 1:size(stimulus,1))
                    for(y = 1:size(stimulus,2))
                        stimulus2(x,y,1:3) = reshape(map(stimulus(x,y)+1,:),[1,1,3]);
                        
                    end
                end
                stimulus = stimulus2;
            end
            
            
            
            if (Parameters.vpixx.M16==0 | Parameters.vpixx.enabled ==0)
                stimulus = double(stimulus);
                if(max(max(max(stimulus)))==1);
                    stimulus = stimulus * 255;
                end
            end
            
            xdim = size(stimulus,2);    %get the x and y size
            ydim = size(stimulus,1);
            pixcount = stimulus(:,:,1)==0;
            pixcount = sum(sum(pixcount));
            originalstimulus = stimulus;
            
            %now add the transparency and do the boundary clipping if they are enabled
            
            if(tthresh> -1)  %transparency threshold is enabled...
                if (size(stimulus,3) > 1)
                    collapsed = mean(stimulus(:,:,:),3);   %trim off the 2nd & 3rd color index, converting this to a monochrome bitmap
                else
                    collapsed = stimulus;
                end
                alphamap = 255- ((collapsed(:,:,1) >tthresh) *255);   %pixels lighter than tthresh are going to be made transparent
                
                %starting from the middle of the stimulus, find the leftedge of
                %the transparency mask
                
                [x x1] = max(mean(alphamap,1) > 0);
                %starting from the middle of the stimulus, find the rightedge
                [x x2] = max(flipdim(mean(alphamap,1),2) > 0);
                x2 = xdim-x2;
                
                %starting from the middle find the top edge
                [x y1] = max(mean(alphamap,2) > 0);
                %starting from the middle find the bottom edge
                [x y2] = max(flipdim(mean(alphamap,2),1) > 0);
                y2 = ydim-y2;
                
                %add in the clippingboundary
                
                if(boundary > -1) %clippingboundary enabled
                    x2 = (x2+boundary/2);
                    y2 = (y2+boundary/2);
                    
                    %if this is larger than the size of the matrix, enlarge the
                    %matrix to match
                    if(x2 > xdim)
                        stimulus(1,x2,2) =0;
                        
                        alphamap(1,x2) = 0;
                    end
                    if(y2 > ydim)
                        stimulus(y2,1,2) =0;
                        alphamap(y2,1) = 0;
                        
                    end
                    clear stimulus2;
                    clear alphamap2;
                    
                    %reduce the size of the stimulus down to the clipping boundary
                    try
                        stimulus2(1:(y2-y1)+1, boundary/2: boundary/2+ (x2-x1),:) = stimulus(y1:y2,x1:x2,:);
                        alphamap2(1:(y2-y1)+1, boundary/2: boundary/2+ (x2-x1),1) = alphamap(y1:y2,x1:x2);
                        
                        stimulus2(1,x2 + boundary/2,:) = 0;
                        alphamap2(1,x2 + boundary/2,1) = 0;
                        
                        
                        
                        stimulus = stimulus2;
                        alphamap = alphamap2;
                        xdim = size(stimulus,2);    %get the x and y size
                        ydim = size(stimulus,1);
                        
                    catch
                        sca
                        keyboard
                    end
                    
                end
                try
                    if (size(stimulus,3) > 1)
                        stimulus(:,:,4) = alphamap;
                    else
                        stimulus(:,:,2) = alphamap;
                    end
                catch
                    sca;
                    beep;
                    StreamDebug = dbstack;
                    ErrorFile = StreamDebug(2).file;
                    ErrorLine = num2str(StreamDebug(2).line);
                    %h = msgbox(stimcheck.errormsg, 'Stimulus Error', 'error');
                    disp(' ');
                    disp('**************************************************');
                    disp('**************************************************');
                    disp('**            ClippingBoundary Error            **');
                    disp('**************************************************');
                    disp('**************************************************');
                    disp(' ');
                    disp(' ');
                    disp('You have tried specify a clippingboundary that will not work');
                    disp('Please check the documentation to see acceptable values.');
                    tempstring = sprintf('This occurred on line %s in file %s',eval(ErrorLine),ErrorFile);
                    disp(tempstring)
                    disp('**************************************************');
                    disp('**************************************************');
                    disp('**************************************************');
                    disp('**************************************************');
                    disp(' ');
                    ListenChar(1);
                    
                    try
                        if ispc
                            try
                                ShowHideFullWinTaskbarMex(1);
                            catch ME
                                ShowHideWinTaskbarMex(1);
                            end
                        end
                    end
                    keyboard;
                end
                
                pixcount2 = stimulus(:,:,2)==255;  %how many pixels are present in the mask?
                pixcount2 = sum(sum(pixcount2));
            else
                if(length(alph) > 0)
                    
                    if(size(stimulus,3) ==3)
                        stimulus(:,:,4) = alph;
                    else
                        stimulus(:,:,2) = alph;
                    end
                    
                end
                
                pixcount2 = sum(sum(sum(stimulus)));  %a color stimulus, set pixcount2 to the total visual energy of the stimulus
            end
            
            Stimuli_set.xdim(stim)  = size(stimulus,2);  %get the size of the stimulus
            Stimuli_set.ydim(stim)  = size(stimulus,1);
            Stimuli_set.pixcount(stim)  = pixcount2;
            
            if(Parameters.vpixx.M16 & Parameters.vpixx.enabled)
                stimulus = stimulus/255;
            end
            
            %Create the texture will all of the specifications applied:
            Texturepointer = Screen('MakeTexture', Parameters.window, stimulus,[], [], Parameters.textureFloatPrecision);
            Stimuli_set.pointer(stim) =   Texturepointer;
            
            %Save the stimulus if savestim enabled
            if(Stimuli_set.savestim)
                Stimuli_set.stimuli{stim} = stimulus;
            else
                Stimuli_set.stimuli{stim} = 0;
            end
            
            
            
        case 2   %Text Stimulus:
            
            
            Stimuli_set.stimnames{stim} = stimuli{stim};
            
            try
                Stimuli_set.font{stim} =  stimstruct.font{stim};  %is there a font specified for each individual stimulus?
            catch
                Stimuli_set.font{stim} =  stimstruct.font{1};   %nope, just one font, apply it to all of them.
            end
            
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;
            end
            
            try
                Stimuli_set.color(1:3,stim) = stimstruct.color(stim,1:3);
            catch
                Stimuli_set.color(1:3,stim) = stimstruct.color(1:3);
            end
            
            try
                Stimuli_set.wrapat(stim) = stimstruct.wrapat(stim);
            catch
                Stimuli_set.wrapat(stim) = stimstruct.wrapat;
            end
            
            try
                Stimuli_set.vSpacing(stim) = stimstruct.vSpacing(stim);
            catch
                Stimuli_set.vSpacing(stim) = stimstruct.vSpacing;
            end
            
            
            Stimuli_set.clippingboundary(stim) =0;
            Stimuli_set.transparencythreshold(stim) = 0;
            
            Screen('TextSize',Parameters.window,Stimuli_set.stimsize(stim));
            Stimuli_set.font;
            
            Stimuli_set.font{stim};
            
            Screen('TextFont',Parameters.window,Stimuli_set.font{stim});
            
            
            [x y normBoundsRect] = DrawFormattedTextBounds(Parameters.window, stimuli{stim},0,0,[],Stimuli_set.wrapat(stim),0,0,Stimuli_set.vSpacing(stim),0);
            
            
            Stimuli_set.xdim(stim) = normBoundsRect(3);
            Stimuli_set.ydim(stim) = normBoundsRect(4);
            Stimuli_set.pixcount(stim) = 0;
            Stimuli_set.pointer(stim) = 0;
            Stimuli_set.stimuli{stim} =  [];
            
            
        case 3   %Psychtoolbox shape
            
            Stimuli_set.stimnames{stim} = stimuli{stim};
            Stimuli_set.font{stim} =  0;
            Stimuli_set.clippingboundary(stim) = 0;
            Stimuli_set.transparencythreshold(stim) = 0;
            
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;
            end
            
            try
                Stimuli_set.color(1:3,stim) = stimstruct.color(stim,1:3);
            catch
                Stimuli_set.color(1:3,stim) = stimstruct.color(1:3);
            end
            
            try
                Stimuli_set.xdim(stim) =  stimstruct.xdim(stim);
            catch
                Stimuli_set.xdim(stim) =  stimstruct.xdim;
            end
            try
                Stimuli_set.ydim(stim) =  stimstruct.ydim(stim);
            catch
                Stimuli_set.ydim(stim) =  stimstruct.ydim;
            end
            
            try
                Stimuli_set.linelength(stim) =  stimstruct.linelength(stim);
            catch
                Stimuli_set.linelength(stim) =  stimstruct.linelength;
            end
            try
                Stimuli_set.linewidth(stim) =  stimstruct.linewidth(stim);
            catch
                Stimuli_set.linewidth(stim) =  stimstruct.linewidth;
            end
            try
                Stimuli_set.lineangle(stim) =  stimstruct.lineangle(stim);
            catch
                Stimuli_set.lineangle(stim) =  stimstruct.lineangle;
            end
            try
                Stimuli_set.pointlist{stim} =  stimstruct.pointlist{stim,:};
            catch
                Stimuli_set.pointlist{stim} =  stimstruct.pointlist;
            end
            
            
            Stimuli_set.pixcount(stim) = 0;
            Stimuli_set.pointer(stim) = 0;
            Stimuli_set.stimuli{stim} =  [];
            
            
            
        case 4   %movie
            
            s = sprintf('%s%s%s',Parameters.workingdir,Parameters.stimulidir,stimuli{stim});
            
            Stimuli_set.stimnames{stim} = stimuli{stim};
            
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;
            end
            
            Stimuli_set.xdim(stim) = 0; %normBoundsRect(3);
            Stimuli_set.ydim(stim) = 0; %normBoundsRect(4);
            
            [ Stimuli_set.pointer(stim) movieduration fps imgw imgh] = Screen('OpenMovie', Parameters.window, s,[],1);
            %[movie movieduration fps imgw imgh] = Screen('OpenMovie', win, moviename, [], preloadsecs, [], pixelFormat, maxThreads);
            Screen('SetMovieTimeIndex', Stimuli_set.pointer(stim), 0);
            Stimuli_set.stimsize(stim) = movieduration;
            Stimuli_set.color(1,stim) = fps;
            Stimuli_set.color(2,stim) = imgw;
            Stimuli_set.color(3,stim) = imgh;
            
            Stimuli_set.stimuli{stim} =  [];
            
        case (5)  %audio
            
            s = sprintf('%s%s%s',Parameters.workingdir,Parameters.stimulidir,stimuli{stim});
            
            Stimuli_set.stimnames{stim} = stimuli{stim};
            
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;
            end
            
            try
                Stimuli_set.audiowait(stim) = stimstruct.audiowait(stim);
            catch
                Stimuli_set.audiowait(stim) = stimstruct.audiowait;
            end
            
            
            try
                Stimuli_set.xdim{stim} =  stimstruct.xdim{stim};
            catch
                Stimuli_set.xdim{stim} =  stimstruct.xdim;
            end
            
            try
                Stimuli_set.ydim{stim} =  stimstruct.ydim{stim};
            catch
                Stimuli_set.ydim{stim} =  stimstruct.ydim;
            end
            
            try
                Stimuli_set.volume(stim) =  stimstruct.volume{stim};
            catch
                Stimuli_set.volume(stim) =  stimstruct.volume;
            end
            
            try
                Stimuli_set.monoaudio(stim) = stimstruct.monoaudio(stim);
            catch
                Stimuli_set.monoaudio(stim) = stimstruct.monoaudio;
            end
            
            
            try
                %load in the audio file
                Stimuli_set.stimuli{stim} = audioread(s)*Stimuli_set.volume(stim);
                %create a temporary version so that we can assemble a two channel version if necessary
                tempstim =    Stimuli_set.stimuli{stim};
                tempstim =    tempstim(:,1);
                
                Stimuli_set.stimsize(stim) = length(tempstim)/Parameters.freq;   % length in seconds
                
                % is it a mono sound?
                if(Stimuli_set.monoaudio(stim) =='d')
                    if size(Stimuli_set.stimuli{stim},2) ==2
                        Stimuli_set.monoaudio(stim) = 's';
                    else
                        
                        Stimuli_set.monoaudio(stim) = 'b';
                    end
                    
                end
                if(Stimuli_set.monoaudio(stim) ~='s')
                    if (Stimuli_set.monoaudio(stim) == 'l')% play in left ear only?
                        Stimuli_set.pointer(stim)= PsychPortAudio('CreateBuffer', Parameters.pahandle, [tempstim';zeros(length(tempstim),1)']);
                    elseif (Stimuli_set.monoaudio(stim) == 'r')% play in right ear only?
                        Stimuli_set.pointer(stim)= PsychPortAudio('CreateBuffer', Parameters.pahandle, [zeros(length(tempstim),1)';tempstim']);
                    else
                        % create a bilateral mono sound
                        Stimuli_set.pointer(stim)= PsychPortAudio('CreateBuffer', Parameters.pahandle, [Stimuli_set.stimuli{stim}';Stimuli_set.stimuli{stim}']);
                    end
                    
                else  %else it's a stereo sound
                    try
                        Stimuli_set.pointer(stim)= PsychPortAudio('CreateBuffer', Parameters.pahandle, [Stimuli_set.stimuli{stim}']);
                    catch
                        sca;
                        beep;
                        StreamDebug = dbstack;
                        ErrorFile = StreamDebug(2).file;
                        ErrorLine = num2str(StreamDebug(2).line);
                        %h = msgbox(stimcheck.errormsg, 'Stimulus Error', 'error');
                        disp(' ');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp('**          Audio File Error            **');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp(' ');
                        disp(' ');
                        disp('You have tried to load a monaural .wav file as a stereo file');
                        disp('You can fix this by changing stimstruct.monoaudio to d instead of s');
                        tempstring = sprintf('This occurred on line %s in file %s',eval(ErrorLine),ErrorFile);
                        disp(tempstring)
                        disp('**************************************************');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp(' ');
                        ListenChar(1);
                        
                        try
                            if ispc
                                try
                                    ShowHideFullWinTaskbarMex(1);
                                catch ME
                                    ShowHideWinTaskbarMex(1);
                                end
                            end
                        end
                        keyboard;
                    end
                    
                    
                end
            catch
                fprintf(errors,'Could not load stimulus %s\n',s);
                stimulus = zeros(20,20,3);
                rethrow(lasterror)
                
            end
            
            if(Stimuli_set.savestim ==0)
                Stimuli_set.stimuli{stim} = 0;
                
            end
            
            
            
        case (6)  %create a imagefont
            
            
            Stimuli_set.basename = stimstruct.basename;
            Stimuli_set.basename_suffix = stimstruct.basename_suffix;
            Stimuli_set.transparencythreshold = stimstruct.transparencythreshold;
            Stimuli_set.clippingboundary = stimstruct.clippingboundary;
            
            
            
            %Load in the Csv fonttable for the font set selected
            fname = sprintf('%s%s_imagefont.csv',Parameters.stimulidir,stimstruct.basename);
            fonttable = csvread(fname);
            numchars = size(fonttable,1);
            
            
            
            %Load in the characters of the selected font
            for(chars = 1: numchars)
                
                charactername= sprintf('%s%s_%d%s',Parameters.stimulidir,Stimuli_set.basename,chars,Stimuli_set.basename_suffix);
                
                try
                    [charimages{chars}, map, alphas{chars}] = imread(charactername);   %read in the stimulus for this array position
                catch
                    [charimages{chars}] = zeros(50,50)+255;
                    map= [];
                    alphas{chars}= zeros(50,50);
                end
                
                
                alph = alphas{chars};
                stimulus = charimages{chars};
                
                
                if(size(map,1) >0)  %this is a colormapped image, let's turn this into RGB
                    stimulus2 = 0;
                    for(x = 1:size(stimulus,1))
                        for(y = 1:size(stimulus,2))
                            stimulus2(x,y,1:3) = reshape(map(stimulus(x,y)+1,:),[1,1,3]);
                            
                        end
                    end
                    stimulus = stimulus2;
                end
                
                
                xdim = size(stimulus,2);    %get the x and y size
                ydim = size(stimulus,1);
                pixcount = stimulus(:,:,1)==0;
                pixcount = sum(sum(pixcount));
                originalstimulus = stimulus;
                
                
                %Apply the transparancy mask
                if(Stimuli_set.transparencythreshold> -1)  %transparency threshold is enabled...
                    
                    if (size(stimulus,3) > 1)
                        collapsed = mean(stimulus(:,:,:),3);   %trim off the 2nd & 3rd color index, converting this to a monochrome bitmap
                    else
                        collapsed = stimulus;
                    end
                    alphamap = 255- ((collapsed(:,:,1) >Stimuli_set.transparencythreshold) *255);   %pixels lighter than tthresh are going to be made transparent (if transparency is enabled)
                    
                    %starting from the middle of the stimulus, find the leftedge of
                    %the transparency mask
                    
                    
                    [x x1] = max(mean(alphamap,1) > 0);
                    %starting from the middle of the stimulus, find the rightedge
                    [x x2] = max(flipdim(mean(alphamap,1),2) > 0);
                    x2 = xdim-x2;
                    
                    %starting from the middle find the top edge
                    [x y1] = max(mean(alphamap,2) > 0);
                    %starting from the middle find the bottom edge
                    [x y2] = max(flipdim(mean(alphamap,2),1) > 0);
                    y2 = ydim-y2;
                    
                    try
                        Stimuli_set.clippingboundary(stim) = stimstruct.clippingboundary(stim);
                        boundary = stimstruct.clippingboundary(stim);
                    catch
                        Stimuli_set.clippingboundary(stim) = stimstruct.clippingboundary;
                        
                        boundary = stimstruct.clippingboundary;
                    end
                    
                    %add in the boundary
                    if(Stimuli_set.clippingboundary > -1)
                        x2 = (x2+boundary/2);
                        y2 = (y2+boundary/2);
                        
                        %if this is larger than the size of the matrix, enlarge the
                        %matrix to match
                        if(x2 > xdim)
                            stimulus(1,x2,2) =0;
                            
                            alphamap(1,x2) = 0;
                        end
                        if(y2 > ydim)
                            stimulus(y2,1,2) =0;
                            alphamap(y2,1) = 0;
                            
                        end
                        
                        clear stimulus2;
                        clear alphamap2;
                        
                        %reduce the size of the stimulus down to the clipping boundary
                        try
                            stimulus2(1:(y2-y1)+1, boundary/2: boundary/2+ (x2-x1),:) = stimulus(y1:y2,x1:x2,:);
                            alphamap2(1:(y2-y1)+1, boundary/2: boundary/2+ (x2-x1),1) = alphamap(y1:y2,x1:x2);
                            
                            stimulus2(1,x2 + boundary/2,:) = 0;
                            alphamap2(1,x2 + boundary/2,1) = 0;
                            
                            stimulus = stimulus2;
                            alphamap = alphamap2;
                            xdim = size(stimulus,2);    %get the x and y size
                            ydim = size(stimulus,1);
                        catch
                            sca;
                            beep;
                            StreamDebug = dbstack;
                            ErrorFile = StreamDebug(2).file;
                            ErrorLine = num2str(StreamDebug(2).line);
                            %h = msgbox(stimcheck.errormsg, 'Stimulus Error', 'error');
                            disp(' ');
                            disp('**************************************************');
                            disp('**************************************************');
                            disp('**            ClippingBoundary Error            **');
                            disp('**************************************************');
                            disp('**************************************************');
                            disp(' ');
                            disp(' ');
                            disp('You have tried specify a clippingboundary that will not work');
                            disp('Please check the documentation to see acceptable values.');
                            tempstring = sprintf('This occurred on line %s in file %s',eval(ErrorLine),ErrorFile);
                            disp(tempstring)
                            disp('**************************************************');
                            disp('**************************************************');
                            disp('**************************************************');
                            disp('**************************************************');
                            disp(' ');
                            ListenChar(1);
                            
                            try
                                if ispc
                                    try
                                        ShowHideFullWinTaskbarMex(1);
                                    catch ME
                                        ShowHideWinTaskbarMex(1);
                                    end
                                end
                            end
                            keyboard;
                        end
                        
                    end
                    
                    
                    try
                        if (size(stimulus,3) > 1)
                            stimulus(:,:,4) = alphamap;
                        else
                            stimulus(:,:,2) = alphamap;
                        end
                    catch
                        sca;
                        beep;
                        StreamDebug = dbstack;
                        ErrorFile = StreamDebug(2).file;
                        ErrorLine = num2str(StreamDebug(2).line);
                        %h = msgbox(stimcheck.errormsg, 'Stimulus Error', 'error');
                        disp(' ');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp('**            ClippingBoundary Error            **');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp(' ');
                        disp(' ');
                        disp('You have tried specify a clippingboundary that will not work');
                        disp('Please check the documentation to see acceptable values.');
                        tempstring = sprintf('This occurred on line %s in file %s',eval(ErrorLine),ErrorFile);
                        disp(tempstring)
                        disp('**************************************************');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp('**************************************************');
                        disp(' ');
                        ListenChar(1);
                        
                        try
                            if ispc
                                try
                                    ShowHideFullWinTaskbarMex(1);
                                catch ME
                                    ShowHideWinTaskbarMex(1);
                                end
                            end
                        end
                        keyboard;
                    end
                else
                    
                    %%Transparency threshold method of creating an alpha mask
                    if(length(alph) >0 ) %but there is no alpha mask included with the image, so we make one and crop the image
                        
                        if(size(stimulus,3) ==3)
                            stimulus(:,:,4) = alph;
                        else
                            stimulus(:,:,2) = alph;
                        end
                        
                        
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                Charxdim(chars) = xdim;
                Charydim(chars) = ydim;
                
                Chararray{chars} = stimulus;
                
            end
            
            %Determine the imagefont stimulus
            Stimuli_set.stimnames{stim}= stimuli{stim};
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;
            end
            
            word = stimuli{stim};
            
            %now glue the characters together to form a complete word
            wordstimulus = 0;
            startx = 1;
            for(c = 1:length(word))
                
                letterindex = find(fonttable(:,2) == word(c));
                
                
                
                xdim = Charxdim(letterindex);
                ydim = Charydim(letterindex);
                
                try
                    if(size(Chararray{letterindex},3) ==4)
                        wordstimulus(1:ydim,startx:startx+xdim-1,1:4)= Chararray{letterindex}; %RGB char
                    elseif(size(Chararray{letterindex},3) ==3)
                        wordstimulus(1:ydim,startx:startx+xdim-1,1:3)= Chararray{letterindex}; %RGB char
                    elseif(size(Chararray{letterindex},3) ==2)
                        wordstimulus(1:ydim,startx:startx+xdim-1,1:2)= Chararray{letterindex};  %Mono char
                    elseif(size(Chararray{letterindex},3) ==1)
                        wordstimulus(1:ydim,startx:startx+xdim-1,1:1)= Chararray{letterindex};  %Mono char
                    end
                catch
                    sprintf('You have tried to present a Character that is not located in the imagefont CSV')
                end
                
                startx = startx+xdim;
            end
            
            
            Stimuli_set.xdim(stim) = size(wordstimulus,2);
            Stimuli_set.ydim(stim) =  size(wordstimulus,1);
            Stimuli_set.pixcount(stim) = 0;
            
            
            Stimuli_set.pointer(stim)=Screen('MakeTexture', Parameters.window, wordstimulus,[], [], Parameters.textureFloatPrecision);
            
            if(Stimuli_set.savestim)
                Stimuli_set.stimuli = Chararray;
            else
                Stimuli_set.stimuli = 0;
            end
            
            
        case 7 % gabor
            
            Stimuli_set.stimuli{stim} =  [];
            
            try
                Stimuli_set.stimsize(stim) = stimstruct.stimsize(stim);   %if we've passed in multiple sstimsizes, assign one to each stimulus
            catch
                Stimuli_set.stimsize(stim) = stimstruct.stimsize;         %otherwise there's just one stimsize assigned to each of them
            end
            
            
            % gabor variables
            try
                Stimuli_set.norm_freq(stim) = stimstruct.norm_freq(stim);
            catch
                Stimuli_set.norm_freq(stim) = stimstruct.norm_freq;
            end
            try
                Stimuli_set.orient_deg(stim) = stimstruct.orient_deg(stim);
            catch
                Stimuli_set.orient_deg(stim) = stimstruct.orient_deg;
            end
            try
                Stimuli_set.phase(stim) = stimstruct.phase(stim);
            catch
                Stimuli_set.phase(stim) = stimstruct.phase;
            end
            try
                Stimuli_set.bg_contrast(stim) = stimstruct.bg_contrast(stim);
            catch
                Stimuli_set.bg_contrast(stim) = stimstruct.bg_contrast;
            end
            try
                Stimuli_set.bg_contrast(stim) = stimstruct.bg_contrast(stim);
            catch
                Stimuli_set.bg_contrast(stim) = stimstruct.bg_contrast;
            end
            try
                Stimuli_set.sigma(stim) = stimstruct.sigma(stim);
            catch
                Stimuli_set.sigma(stim) = stimstruct.sigma;
            end
            try
                Stimuli_set.contrast(stim) = stimstruct.contrast(stim);
            catch
                Stimuli_set.contrast(stim) = stimstruct.contrast;
            end
            %             try
            %                 Stimuli_set.window{stim} = stimstruct.window{stim};   %if we've passed in multiple sstimsizes, assign one to each stimulus
            %             catch
            %                 Stimuli_set.window{stim} = stimstruct.window;         %otherwise there's just one stimsize assigned to each of them
            %             end
            
            
            Stimuli_set.stimnames{stim} = stimuli{stim};  %filenames of the textures
            gaborsize = (Stimuli_set.stimnames{stim});
            
            % make the gabor
            stimulus = make_gabor(gaborsize, 'norm_freq', Stimuli_set.norm_freq(stim), 'orient_deg', Stimuli_set.orient_deg(stim), 'phase', Stimuli_set.phase(stim), 'bg_contrast', Stimuli_set.bg_contrast(stim)/255, 'sigma', Stimuli_set.sigma(stim), 'contrast', Stimuli_set.contrast(stim));%, 'window', Stimuli_set.window(stim));
            % get the stimulus size
            Stimuli_set.xdim(stim)  = size(stimulus,2);
            Stimuli_set.ydim(stim)  = size(stimulus,1);
            
            % convert the gabor to 256 color space
            for (x = 1:size(stimulus,2))
                for (y = 1:size(stimulus,1))
                    stimulus(x,y) = stimulus(x,y);
                end
            end
            
            
            if(~Parameters.vpixx.M16 | ~Parameters.vpixx.enabled )
                stimulus = ceil(stimulus*255);
            end
            
            
            Texturepointer = Screen('MakeTexture', Parameters.window, stimulus,[], [], Parameters.textureFloatPrecision);
            Stimuli_set.pointer(stim) = Texturepointer;
            
            
        case 8    %this is a color wheel
            
            
            s= sprintf('%s%s',Parameters.stimulidir,'colorwheel360.mat');
            
            Radius = stimuli{stim};
            
            colors = load(s, 'fullcolormatrix');
            Stimuli_set.colorwheel{stim} = colors.fullcolormatrix;
            
            
            Stimuli_set.colorWheelLocations{stim} =  [cosd([1:360]).*Radius + Parameters.centerx; ...
                sind([1:360]).*Radius + Parameters.centery];
            
            Stimuli_set.colorWheelSizes(stim) = 20;
            Stimuli_set.xdim(stim) = 0;
            Stimuli_set.ydim(stim) = 0;
            Stimuli_set.stimsize(stim) = 0;
            
            
    end
    
    %Draw PTB shapes for the progress bar
    if Parameters.Progressbarenabled == 1;
        done = done + 1;
        Screen(Parameters.window,'TextFont',['Arial']);
        Screen(Parameters.window,'TextSize',[22]);
        Screen('DrawText', Parameters.window, 'Preparing Stimuli. Please Wait.',[Parameters.centerx - 250],[Parameters.centery - 100],[0,0,0]);
        Screen('FrameRect', Parameters.window, [0,0,0], [(Parameters.centerx - 250) (Parameters.centery-50) (Parameters.centerx +250) (Parameters.centery + 50)], [1]);
        Screen('FillRect', Parameters.window, [0,0,0], [(Parameters.centerx - 250) (Parameters.centery-50) (Parameters.centerx - 250 + 500*(done/Parameters.Progressbaritems)) (Parameters.centery + 50)], [1]);
        Screen('Flip', Parameters.window);
    end
end


fclose(errors);

end
