function Demodata = Fulldemographics(Parameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A multi-purpose experimental toolkit for creating experiments easily using Matlab and Psychtoolbox-3
% Includes optional EEG and Eyelink functionality
% maintained by Brad Wyble, with helpful contributions
% from Patrick Craston, Srivas Chennu, Marcelo Gomez, Syed Rahman & Asli
% Kilic, Michael Romano and especially Greg Wade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Fulldemographics
% Allows for the collection of demographic data before the experiment begins.  
%
% Input
%    Parameters: Parameters set for this experiment if previously set
%
%Fulldemographics is called by:
%    Runexp
%
%Comments in this function are designed to be used with
%TutorialS10_FullDemo. Please see the tutorial documentation for an
%explaination of how to edit this function.

if(Parameters.disableinput == 0)   %skip the demographics dialog if we're in disableinput mode
    %EDITHERE_prompt
    %Initial welcome message box text
    prompttxt = sprintf(['Thanks for participating in this experiment.\n\n'...
        'The following screen will ask you questions about your age, sex, handedness, vision, and how much time you spend on a computer.'...
        'You will also be asked questions about language fluency.' ...
        'Please use the TAB button to switch between input fields.\nYour data will remain confidential.'...
        '\n\nClick the OK button to continue.']);
    msg = msgbox(prompttxt,'Welcome!');
    uiwait(msg);
    
    s_num = '1';
    s_num2 = '2';
    
    %EDITHERE_demographics
    
    %Edit the Demo questions here
    prompts = {'Subject Number','Age','Sex (M/F)','Handedness (R/L)','How many hours do you use the computer each day?','How many times in a week do you play action computer games?','Please re-enter the subject number'};
    
    %Edit the default answers here  (or leave them as '' for blank)
    default_s_info = {'','', '', '', '', '', ''};
    
    validinput = 0;
    %set up a loop to make sure all information is correct before
    %continuing to the experimental blocks
    while  validinput ==0   
        
        %this line puts up the Question box
        s_info = inputdlg(prompts, 'Tell us some things about yourself', 1, default_s_info,struct('WindowStyle','normal'));
        
        %Assign names to each of the variables
        try
            [s_num, s_age, s_sex, s_hand, s_computer,s_games,s_num2] = deal(s_info{:});
        catch
            error('Demographics data not entered')
            
        end
        
        
        %If any of these answers should be converted into a numeric
        %value, do that here with eval
        %if any of these fail to work, catch the error and try again
        
        if(length(s_num2)==0)
            s_num2 = 'BLANK';
        end
        
        % we confirm that the subject number is entered correctly by having it re-entered at the top and bottom of this form
        if strcmp(s_num, s_num2) == 1
            validinput =1;
        elseif strcmp(s_num, s_num2) == 0;
            default_s_info = s_info;
            validinput = 0;
        end
       
        
    end
    
    %Put the answers into the demodata stucture, which is stored in UserData
    
    Demodata.s_num = s_num;
    Demodata.s_age = s_age;
    Demodata.s_sex = s_sex;
    Demodata.s_hand = s_hand;
    Demodata.s_computer = s_computer;
    Demodata.s_games = s_games;
    Demodata.filename = Parameters.datafilename;
    
else
    Demodata.s_num = '999';
    Demodata.filename = Parameters.datafilename;
end





