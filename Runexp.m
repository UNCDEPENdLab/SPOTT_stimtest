function  FullUserdata =  Runexp(testingmode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Runexp(testingmode)
%Runexp is the function you will call to run an experiment that you have
%finished editing in Stream. 
%
%testingmode:
%
%If testingmode = 0: Will run the designated block files defined in
%Setparameters with the collection of demographic data
%(FullDemographics)
%
%If testingmode >= 0: skip demographics and run just this block number
%
%If testingmode = char: Run the block file with the name testingmode 
%
%Runexp.m calls the following Stream functions:
%   Setparameters
%   FullDemographics
%   Preparescreen
%   ShowError
%   Streamcleanup
%   Sendmarkerwpause
%   Runblock
%   WriteDataFiles

tic %start the timer

if(nargin ==0)
    testingmode = 0;
end

try
    if ispc
        try
            ShowHideFullWinTaskbarMex(0);
        catch ME
            ShowHideWinTaskbarMex(0);
        end
    end
end

%seed the RNG based on the current millisecond
currtime = GetSecs;
currtime = currtime- floor(currtime);
temp = ceil(currtime*1000);
for(i = 1:temp)
    a = rand;
end

addpath 'Blocks';
addpath 'StreamCore';

Parameters = Setparameters([]);   %start off with default parameters

if(Parameters.eyetracking && Parameters.TobiiX2)
    if IsOSX | IsLinux
        addpath 'StreamCore/OtherCode/TobiiUtilities';
        addpath 'StreamCore/OtherCode/tetio';
    else
        addpath 'StreamCore\OtherCode\TobiiUtilities';
        addpath 'StreamCore\OtherCode\tetio';
    end
end
    if IsOSX | IsLinux
        save('StreamCore/blockvars','a')
    else
        save('StreamCore\blockvars','a')
    end

%the try/catch command, which we use here, allows us to attempt to execute
%some code, and then catch the error and exit gracefully if it crashes.

try
    %collect demographics if we're running the entire experiment
    if(testingmode ==0)
        FullUserdata.Demodata = Fulldemographics(Parameters);
    else
        FullUserdata.Demodata.s_num = '999';%otherwise just set the subject number to 999
        FullUserdata.Demodata.filename = Parameters.datafilename;
    end
    
    Parameters = Preparescreen(Parameters);    %initialize the PTB screen
      
if(Parameters.eyetracking && Parameters.Eyelink)
        edfFile=sprintf('%s%s',Parameters.edffilename,  FullUserdata.Demodata.s_num );
        Eyelink('Openfile', edfFile);
    end
catch  errormessage %whoops, something went wrong in the previous block of code, display the error and exit
      
    ListenChar(1);%Return keyboard control to the command window
    sca
    Showerror(errormessage); % These were commented out in the addition of new error catching functions
    ShowCursor
    Streamcleanup
    try
        if ispc
            try
                ShowHideFullWinTaskbarMex(1);
            catch ME
                ShowHideWinTaskbarMex(1);
            end
        end
    end
    return
end

sendmarkerwpause(Parameters, Parameters.MARKERS.STARTEXP);   %you will find these marker statements scattered throughout the code
%they send trigger pulses over the parallel port as triggers to an EEG system.

ListenChar(2);  %Prevent keyboard input from echoing to the MATLAB command window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preparing Stimuli

HideCursor;   %take the mouse cursor off the screen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show the blocks to the subject
% EDITHERE_blocks to change the block ordering as a function of subject number

Parameters = Setparameters(Parameters,FullUserdata);  %set the parameters back to their default value

carryover.dummy = 0;

%A simple example of how to do odd/even counterbalancing across subjects
blocklist = Parameters.blocklist;   %list of block types to run

if(testingmode > 0)     %if we are in testing mode, ignore the block list and just use the block that was passed in as an argument
    blocklist = {testingmode};
end

blocknum = 0;
for(blocktype = blocklist)   %loop through the list of blocks one at a time
    if(Parameters.blockrestart)
        Parameters = Preparescreen(Parameters);    %initialize the PTB screen
    end
    
    blocknum = blocknum + 1;  
    
    [FullUserdata carryover] = Runblock(Parameters,FullUserdata,blocktype,blocknum,carryover);
    
    if(Parameters.blockrestart)
        sca
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%
%At this point the experiment is over!
%%%%%%%%%%%%%%%%%%%
%Time for cleanup
%save the data to disk
fname = sprintf('%s%s%s',Parameters.datadir,Parameters.datafilename,FullUserdata.Demodata.s_num);
save(fname,'FullUserdata');

ListenChar(1);%Return keyboard control to the command window

if(Parameters.eyetracking)  %if we were eyetracking, stop, and download the datafile
    
    if(Parameters.Eyelink)
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        try
            sprintf('Receiving data file ''%s''\n', edfFile)
            status=Eyelink('ReceiveFile');%,edfFile,edfFile,Parameters.datadir );
            if status > 0
                sprintf('ReceiveFile status %d\n', status)
            end
            if 2==exist(edfFile, 'file')
                sprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd )
            end
        catch
            sprintf('Problem receiving data file ''%s''\n', edfFile )
        end
    end
    
end

sca    %shutdown PTB

expduration = num2str(ceil(toc/60));
disp(['This experiment run took '  expduration ' minutes.']);

if(testingmode ==0)
    msg = msgbox('The experiment is over!','Farewell');
    uiwait(msg);
end
ShowCursor;
%WriteDataFiles(FullUserdata);
sendmarkerwpause(Parameters,Parameters.MARKERS.ENDEXP);
Streamcleanup;
try
    if ispc
        try
            ShowHideFullWinTaskbarMex(1);
        catch ME
            ShowHideWinTaskbarMex(1);
        end
    end
end
%so long!

