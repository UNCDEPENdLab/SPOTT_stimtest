function Parameters = Preparescreen(Parameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preparescreen(Parameters)
% Preparescreen will open up the Psychtoolbox screen 
% for presenting your experiment as well as establishing any screen parameters set
%
% Input
%    Parameters: Parameter set for this experiment if previously set 
%
%Preparescreen is called by:
%    Runexp
%    Runblock


if Parameters.skipsynctests == 1;
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end

if(Parameters.audioinput |Parameters.audiooutput )
    %sound initilialization is set to work by default
    %if timing is critical for your experiment you are STRONGLY encouraged to check out the Psychtoolbox website for more information
    %about timing and hardware issues.
    InitializePsychSound;   %initialize the audio driver in PTB
    suggestedLatencySecs = 0;
    freq = Parameters.freq;
    
    try
        PsychPortAudio('Close',0);   %shutdown existing audio
    catch
    end
    
    try
        pahandle = PsychPortAudio('Open', [], [], 2, freq, 2, 0, suggestedLatencySecs );
    catch
        pahandle = PsychPortAudio('Open', [], [], 2, freq, 2, 0, suggestedLatencySecs );
    end
    
    if IsOSX
        %Following advice from Psychtoolbox Website:
        % Take hardware delay of MacBookPro into account: Assign it as bias.
        % The DAC delay of Intel HDA onboard audio on MacBookPro is 30 frames,
        % according to spec, so the delay should be 30/frequency seconds. This
        % was empirically found to be true on our test setup.
        
        latbias = (30 / freq);
    else
        %Not a mac, you should figure this out yourself.
        latbias = 0;
    end
    prelat = PsychPortAudio('LatencyBias', pahandle, latbias);
    Parameters.pahandle = pahandle;
end
%see http://docs.psychtoolbox.org/InitializePsychSound for information
%about latency


if(Parameters.ParallelPort & strcmp(computer,'DESKTOP-RG5EK8I'))
    Parameters.ioObj = io64;
    status = io64(Parameters.ioObj);
end


%set Psychtoolbox preferences
Screen('Preference', 'VBLTimestampingMode', 1);
Screen('Preference', 'Verbosity', 1);

%Screen('Preference', 'TextRenderer', 1);
KbName('UnifyKeyNames');

%open an onscreen window
Screen('Preference', 'VisualDebugLevel', 1); % gets rid of the big welcome message (REMOVE THIS BEFORE FINAL VERSION!)



Parameters.textureFilterMode = 1;
Parameters.textureFloatPrecision = 0;

if(Parameters.vpixx.enabled)
    %Many thanks to Peter April for this code.  *ASK HIM TO OK*
    screenNumber=max(Screen('Screens'));
    PsychDataPixx('SetDummyMode', Parameters.vpixx.dummymode);
    AssertOpenGL;
    
    
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
    
    if(Parameters.vpixx.M16)
        PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
        Parameters.textureFilterMode = 0;
        Parameters.textureFloatPrecision = 2;
        
    end
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    oldVerbosity = Screen('Preference', 'Verbosity', 1); % Don?t log the GL stuff
    [Parameters.window, Parameters.Scrnsize] = PsychImaging('OpenWindow', screenNumber,Parameters.backgroundcolor/255);
    Screen('Preference', 'Verbosity', oldVerbosity);
    % Ensure that the graphics board's gamma table does not transform our pixels
    gamma = 2.2;
    PsychColorCorrection('SetEncodingGamma', Parameters.window, 1/gamma);
    
else
    try
        [Resolution] = Screen('Resolution',0,Parameters.ScreenResolutionX, Parameters.ScreenResolutionY);
    catch
        disp(' ');
        disp('**************************************************');
        disp('**************************************************');
        disp('**           Screen Resolution Error            **');
        disp('**************************************************');
        disp('**************************************************');
        disp(' ');
        disp('Stream has failed to change the screen resolution to:');
        tempstring = sprintf('%d x %d',Parameters.ScreenResolutionX, Parameters.ScreenResolutionY);
        disp(tempstring);
        disp('Stream has continued to display your experiment  ');
        disp('with the default screen settings.  ');
        disp(' ');
        disp('**************************************************');
        disp('**************************************************');
        disp('**************************************************');
        disp('**************************************************');
        disp(' ');
        ListenChar(1);

    end
    
    [Parameters.window,Parameters.Scrnsize] = Screen('OpenWindow', Parameters.whichscreen, Parameters.backgroundcolor);
end
[Parameters.fliptime nrValidSamples stddev ] =Screen('GetFlipInterval', Parameters.window);
Parameters.centerx = Parameters.Scrnsize(3)/2;
Parameters.centery = Parameters.Scrnsize(4)/2;


%initialization of connection with Eyelink Gazetracker
if(Parameters.eyetracking)
    [nx, ny, bbox] = DrawFormattedText(Parameters.window, 'Initializing the eye tracker', 'center', 'center',[255,255,255],50);
    Screen('Flip',Parameters.window);
    pause(.3)
    
    if(Parameters.Eyelink)
        
        if EyelinkInit()~=1;
            disp('EYETRACKER INITIALIZATION FAILED')
        end;
        el=EyelinkInitDefaults(Parameters.window);
        Parameters.el = el;
        Eyelink('Command','link_sample_data=LEFT,RIGHT,GAZE,AREA');
        [v vs]=Eyelink('GetTrackerVersion');
        if (Parameters.eyecalibrate)
            [nx, ny, bbox] = DrawFormattedText(Parameters.window, 'Calibrate the eye tracker', 'center', 'center',[255,255,255],50);
            Screen('Flip',Parameters.window);
            pause(.3)
            EyelinkDoTrackerSetup(el); 
            [nx, ny, bbox] = DrawFormattedText(Parameters.window, 'Calibration Finished, please wait', 'center', 'center',[0,0,0],50); 
            Screen('Flip',Parameters.window);
        pause(.3);
        end
       
       
        
        
    elseif (Parameters.TobiiX2)
        try
            tetio_cleanUp;
        end
        
        Screen('TextSize',Parameters.window,40);
        DrawFormattedText(Parameters.window, 'Initializing TOBII Tetio', 'center', 'center',[0,0,0],50);
        Screen('Flip',Parameters.window);
        
        tetio_init();
        
        tetio_connectTracker(Parameters.trackerId)
        
        current_FrameRate = tetio_getFrameRate;
        WaitSecs(.1)
        DrawFormattedText(Parameters.window, sprintf('Framerate %d',current_FrameRate), 'center', 'center',[255,255,255],50);
        Screen('Flip',Parameters.window);
        WaitSecs(.2)
        
        SetCalibParams;
        
        breakLoopFlag=0;
        updateFrequencyInHz = 60;
        
        tetio_startTracking;
        
        validLeftEyePos = 0;
        validRightEyePos = 0;
        while(KbCheck)
        end
        
        while(~breakLoopFlag)
            WaitSecs(1/updateFrequencyInHz);
            
            [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
            
            
            
            if isempty(lefteye)
                continue;
            end
            
            GazeData = ParseGazeData(lefteye(end,:), righteye(end,:)); % Parse last gaze data.
            
            if  (GazeData.left_validity==0) && (GazeData.right_validity==0)
                eyeDotColor = [0 255 0];
            else
                eyeDotColor = [255 255 0];
            end
            ovalsize = 10;
            %left eye
            x =  (1-GazeData.left_eye_position_3d_relative.x)*Calib.mondims.width;
            y =  GazeData.left_eye_position_3d_relative.y*Calib.mondims.height;
            screen(Parameters.window,'FillOval',eyeDotColor,[x-ovalsize,y-ovalsize,x+ovalsize,y+ovalsize]);
            
            x2 =   (1-GazeData.right_eye_position_3d_relative.x)*Calib.mondims.width;
            y2 =  GazeData.right_eye_position_3d_relative.y*Calib.mondims.height;
            screen(Parameters.window,'FillOval',eyeDotColor,[x2-ovalsize,y2-ovalsize,x2+ovalsize,y2+ovalsize]);
            
            screen(Parameters.window,'DrawText','press space bar when both eyes are reliably green',100,100);
            
            Screen('Flip',Parameters.window);
            
            if(KbCheck)
                breakLoopFlag = 1;
            end
        end
        tetio_stopTracking;
        % Perform calibration
        if( Parameters.calibrate)
            SetCalibParams;
            mOrder = randperm(Calib.points.n);
            calibplot = Calibrate_ptb(Calib, mOrder, 0, [],Parameters.window,Parameters.Scrnsize(3),Parameters.Scrnsize(4));
            
            PlotCalibrationPoints_ptb(calibplot ,Calib,Parameters);
            
        end
    end
end


% if(Parameters.useCM5)
%
%     currpath = pwd;
%     added =NET.addAssembly([currpath '\StreamCore\OtherCode\CM.dll']);
%     import CorticalMetrics.*;
%     pause(.1);
%     Parameters.CM5 = CorticalMetrics.CM5;
%     Parameters.CM5.UseInputTrigger = true;
%     Parameters.CM5.UseOutputTriggers = true;
%     Parameters.CM5.Init;
%     Parameters.CM5stim = CorticalMetrics.Stimulus(0,0,0);
%     Datapixx('SetDinDataDirection',65536);  %configure VPIXX output on pin 9.. this may not work for your setup
% end



end


