function stimcheck = CheckStimuli(stimstruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CheckStimuli(stimstruct)
% CheckStimuli will check the stimulus structs that you create in your
% block file and make sure all of the values set are legitimate
% Input
%    stimstruct: defines the current stimstruct that is being checked for
%    errors
%
%CheckStimuli is called by:
%    Preparestimuli


%Set up catch flag
stimcheck.goodstims = 1;
stimcheck.errormsg = [];

% did user set the stimuli?
if (isempty(stimstruct.stimuli))
    stimcheck.goodstims = 0;
    stimcheck.errormsg = 'There are no stimuli.';
end

% valid stim size?
if (stimstruct.stimsize == 0)
    stimcheck.goodstims = 0;
    stimcheck.errormsg = 'You set the stimulus size to zero.';
elseif (stimstruct.stimsize < 0)
    stimcheck.goodstims = 0;
    stimcheck.errormsg = 'You set a negative stimulus size.';
end

% valid colors?
if (stimstruct.color(1) < 0 || stimstruct.color(2) < 0 || stimstruct.color(3) < 0 || stimstruct.color(1) > 255 || stimstruct.color(2) > 255 || stimstruct.color(3) > 255)
    stimcheck.goodstims = 0;
    stimcheck.errormsg = 'Valid color values are between 0 and 255.';
end

% xdim, ydim
if (~isempty(stimstruct.xdim) && ~isempty(stimstruct.ydim))
    if (max(stimstruct.xdim < 0) || max(stimstruct.ydim < 0))
        stimcheck.goodstims = 0;
        stimcheck.errormsg = 'xdim and ydim must be greater than zero.';
    end
end


stimstruct.savestim = 0; % save stimuli; 0 = no; 1 = yes
if (stimstruct.savestim ~= 0 && stimstruct.savestim ~= 1)
    stimcheck.goodstims = 0;
    stimcheck.errormsg = 'savestim parameter is binary, it must be set to 0 or 1.';
    sca;
    beep;
end

% stimstruct.pixcount = [];
if (~isempty(stimstruct.pixcount))
    if (stimstruct.pixcount < 0)
        stimcheck.goodstims = 0;
        stimcheck.errormsg = 'pixcount must be greater than zero.';
    end
end


% was there an error?
if (stimcheck.goodstims == 0)
    sca;
    beep;
    StreamDebug = dbstack;
    ErrorFile = StreamDebug(3).file;
    ErrorLine = num2str(StreamDebug(3).line);
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
    disp(tempstring);
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