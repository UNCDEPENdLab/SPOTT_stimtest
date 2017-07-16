function WriteDataFiles(FullUserdata)
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WriteDataFiles(FullUserdata)
% WriteDataFiles will create files containing variable data from your block files.
% This script will write both a compactand a complete data file which can be used in analysis.
% Input
%    FullUserdata: Structure containing all of the variable data from a
%    block file.
%
%WriteDataFiles calls:
%	Streamcleanup

%
%WriteDataFiles is called by:
%    Runexp



if IsOSX | IsLinux
    csvpath = 'data_export/';
else
    csvpath = 'data_export\';
end

error = 0;

%accumulate the names of all variables
blockaccumnames = {};
accumnames = {};
mouse = 0;

%Loop through the blocks and determine the Block_Export variable names
for block = 1: length(FullUserdata.Blocks)
    blocknames =  fieldnames(FullUserdata.Blocks(block).Block_Export);
    blockaccumnames = unique({blockaccumnames{:} blocknames{:}});
    
    %Loop throught the trials and determine the Trial_Export variable names
    for(trial = 1: length(FullUserdata.Blocks(block).Trials))
        names =  fieldnames(FullUserdata.Blocks(block).Trials(trial).Trial_Export);
        accumnames = unique({accumnames{:} names{:}});
    end
    
end

%Export the demographic data from FullDemographics.m
% Userdata.Demodata = FullUserdata.Demodata;



try
    
    %Loop through the experiment and export the variables where appropriate
    for block = 1: length(FullUserdata.Blocks)
        
        variable = {};
        
        sv = FullUserdata.Blocks(block).Block_Export;  %get the list of Block_Exports for this trial
        blocknames =  fieldnames(sv);
        
        for(var = 1: length(blockaccumnames))  %pre allocate these variables
            variable{var} = 0;
        end
        
        for(var = 1: length(blocknames))  %get the data and data types for each variable
            whichvar = find(strcmp(blocknames(var),blockaccumnames));  %figure out each variable's position in the master variable list
            eval(sprintf('variable{whichvar} = FullUserdata.Blocks(block).Block_Export.%s;',blocknames{var}));
        end
        for(i = 1:length(blockaccumnames))  %now go through the WHOLE list of variables for the experiment and put them into the CSV file
            
            if(length(variable{i})> 0)  %this variable was defined on this trial
                s = sprintf('Userdata.Blocks(%d).Block_Export.%s = variable{i};',block,blockaccumnames{i});
                eval(s);
            else   %not defined on this trial
                s = sprintf('Userdata.Blocks(%d).Block_Export.%s = [];',block,blockaccumnames{i});
                eval(s);
            end
        end
        
        
        
        for(trial = 1: length(FullUserdata.Blocks(block).Trials))
            variable = {};
            
            
            sv = FullUserdata.Blocks(block).Trials(trial).Trial_Export;  %get the list of Trial_Exports for this trial
            names =  fieldnames(sv);
            
            for(var = 1: length(accumnames))  %pre allocate these variables
                variable{var} = 0;
            end
            
            for(var = 1: length(names))  %get the data and data types for each variable
                whichvar = find(strcmp(names(var),accumnames));  %figure out each variable's position in the master variable list
                eval(sprintf('variable{whichvar} = FullUserdata.Blocks(block).Trials(trial).Trial_Export.%s;',names{var}));
            end
            
            
                        for(i = 1:length(accumnames))  
            
                            if(length(variable{i})> 0)  %this variable was defined on this trial
                                s = sprintf('Userdata.Blocks(%d).Trials(%d).Trial_Export.%s = variable{i};',block,trial,accumnames{i});
                                eval(s);
                            else   %not defined on this trial
                                s = sprintf('Userdata.Blocks(%d).Trials(%d).Trial_Export.%s = [];',block,trial,accumnames{i});
                                eval(s);
                            end
                        end
            
        end
    end
    
catch Errormessage
    error = 1;
   
end




if (error)
    sca;
    beep;
    StreamDebug = dbstack;
    ErrorFile = StreamDebug(3).file;
    ErrorLine = num2str(StreamDebug(3).line);
    errmsg1 = 'There was a problem with a Trial_Export variable.';
    errmsg2 = 'Please check that your variables are valid.';    
    disp(' ');
    disp('**************************************************');
    disp('**************************************************');
    disp('**            Trial_Export error               **');
    disp('**************************************************');
    disp('**************************************************');
    disp(' ');
    disp(errmsg1);
    disp(' ');
    disp(errmsg2);
    disp(' ');
    disp('**************************************************');
    disp('**************************************************');
    disp('**************************************************');
    disp('**************************************************');
    disp(' ');
    %figure(h);
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


filename = sprintf('%s%s_compact_%s.mat',csvpath,FullUserdata.Demodata.filename,FullUserdata.Demodata.s_num);


% save(filename,'Userdata');




end
