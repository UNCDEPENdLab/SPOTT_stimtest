function sendmarkerpause(Parameters,value)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sendmarkerpause(Parameters,value)
% sendmarkerpause will send a parallel port marker and will pause the
% experiment for the deswignated time
%
% Input
%    Parameters: Parameter set for this experiment if previously set
%    value:  Value of the parallel port marker
%

if(Parameters.ParallelPort)
    if IsWin
        if strcmp(computer,'PCWIN64')
                io64(Parameters.ioObj,888,value);
        else
            PortIO(2,888,value);
        end
        pause(.04);
        if strcmp(computer,'PCWIN64')
                io64(Parameters.ioObj,888,0);
        else
            PortIO(2,888,0);
        end
        pause(.04);
    end

    
end
end