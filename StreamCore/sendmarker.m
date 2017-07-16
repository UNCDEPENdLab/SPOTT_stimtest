function sendmarker(Parameters,value)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sendmarker(Parameters,value)
% Sends a Parallel port marker without pausing the experiment.
%
% Input
%    Parameters: Parameter set for this experiment if previously set
%    value:  value of the parallel port marker
%
%Setparameters is called by:
%    Showstream

if(Parameters.ParallelPort)
        if(value > 0)
            if(IsWin)
            if strcmp(computer,'PCWIN64')
                io64(Parameters.ioObj,888,value);
            else
                PortIO(2,888,value);
            end
        end
        
    else
        if(IsWin)
            if strcmp(computer,'PCWIN64')
                io64(Parameters.ioObj,888,0);
            else
                PortIO(2,888,0);
            end
        end
        
    end
    
    
end