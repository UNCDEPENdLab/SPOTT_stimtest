%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Streamcleanup
% After Stream has finished running or has unexpectedly crashed, this
% script will shut down the running processes and "cleanup" after Stream.
% 
%StreamCleanup is called by:
%    Runexp
%    Runblock
%    WriteDataFiles


if(Parameters.eyetracking)
    
    if(Parameters.Eyelink)
        Eyelink('ShutDown');
        
    end
    
    if(Parameters.TobiiX2)
        
        try
            tetio_stopTracking;
            tetio_disconnectTracker;
            tetio_cleanUp;
        end
    end
end

if(Parameters.audiooutput)
    try
        PsychPortAudio('Close',Parameters.pahandle);
    end
end

if(Parameters.useCM5)
    if(isfield(Parameters,'CM5'))
        try
            Parameters.CM5.DeInit;
        catch
        end
    end
end

try
    rmpath 'Blocks'
    rmpath 'StreamCore'
    
    
    if(Parameters.eyetracking && Parameters.TobiiX2)
        if IsOSX | IsLinux
            rmpath 'StreamCore/OtherCode/TobiiUtilities';
            rmpath 'StreamCore/OtherCode/tetio';
        else
            rmpath 'StreamCore\OtherCode\TobiiUtilities';
            rmpath 'StreamCore\OtherCode\tetio';
        end
    end
end
