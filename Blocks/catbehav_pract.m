function [Events Parameters Stimuli_sets Block_Export Trial_Export Numtrials] = Demo(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, Events, Block_Export, Trial_Export, Demodata)
load('blockvars')
KbName('UnifyKeyNames');
if strcmp(Modeflag,'InitializeBlock');
    
    %Fixation Cross & Instructions
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'+','At the beginning of each trial, you''ll be given a category.','Once you start the trial, a stream of images will display.','Keep your eyes on the fixation cross and','try to detect objects that fit the category.','Either one or two target objects will','appear within the stream of images.','Report the objects in the order you saw them.','If you only saw one target object,','type in "Nothing" when asked to report the second target object.','Press the Spacebar when you''re ready to begin.'};
    stimstruct.wrapat = 70;
    stimstruct.vSpacing = 3;
    stimstruct.stimsize = 25;
    Stimuli_sets(1) = Preparestimuli(Parameters,stimstruct);
    
    %Prompts
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Rate this image from 1-7','Your partner rated this image:','Rate how close you feel to your partner','Here''s your partner''s rating of closeness to you:'};
    stimstruct.wrapat = 70;
    stimstruct.stimsize = 50;
    Stimuli_sets(2) = Preparestimuli(Parameters,stimstruct);
    
    %"Press Spacebar When Ready"
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'(Press Spacebar when ready)'};
    stimstruct.stimsize = 25;
    Stimuli_sets(3) = Preparestimuli(Parameters,stimstruct);
    
    %Partner's rating
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'1','2','3','4','5','6','7'};
    stimstruct.stimsize = 50;
    Stimuli_sets(4) = Preparestimuli(Parameters,stimstruct);
    
    %Example trial 1
    for ex1 = 5000:5019
        ex_num1 = ex1 - 4999;
        stimstruct = CreateStimStruct('image');
        stimstruct.stimuli =  {[num2str(ex1) '.jpg']};
        Stimuli_sets(89+ex_num1) = Preparestimuli(Parameters,stimstruct);
    end
    
    %Example trial 2
    for ex2 = 6000:6019
        ex_num2 = ex2 - 5999;
        stimstruct = CreateStimStruct('image');
        stimstruct.stimuli =  {[num2str(ex2) '.jpg']};
        Stimuli_sets(109+ex_num2) = Preparestimuli(Parameters,stimstruct);
    end
    
    Numtrials = 3;
    
elseif strcmp(Modeflag,'InitializeTrial');
    
    %Center location of screen
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    Parameters.slowmotionfactor = 1;
    
    %Location Values
    target_loc_left = locx - 275;
    target_loc_right = locx + 275;
    
    %Timing Variables
    instruction_time = 0;
    
    start_time = .1;
    
    fixation_time = .2;
    
    if Trial == 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Instructions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        screen_adj = 75;
        Events = newevent_show_stimulus(Events,82,2,locx,locy-screen_adj*4.5,instruction_time,'screenshot_no','clear_yes');
        Events = newevent_show_stimulus(Events,82,3,locx,locy-screen_adj*3.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,4,locx,locy-screen_adj*2.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,5,locx,locy-screen_adj*1.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,6,locx,locy-screen_adj*.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,7,locx,locy+screen_adj*.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,8,locx,locy+screen_adj*1.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,9,locx,locy+screen_adj*2.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,10,locx,locy+screen_adj*3.5,instruction_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,82,11,locx,locy+screen_adj*4.5,instruction_time,'screenshot_no','clear_no');
        responsestruct = CreateResponseStruct;
        
        responsestruct.x = locx;
        responsestruct.y = locy;
        
        responsestruct.allowedchars = KbName('Space');
        
        Events = newevent_keyboard(Events,instruction_time,responsestruct);
        
        end_time = instruction_time + .01;
        
    elseif Trial == 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Example Trial 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        time_interval = .8;
        disp_time = 1.5 - time_interval; %time when the images start to display after fixation
        
        %Fixation Cross
        Events = newevent_show_stimulus(Events,82,1,locx,locy,fixation_time,'screenshot_no','clear_yes');
        
        Events = newevent_show_stimulus(Events,86,2,locx,locy,start_time,'screenshot_no','clear_yes'); %category
        Events = newevent_show_stimulus(Events,86,5,locx,locy-300,start_time,'screenshot_no','clear_no'); %"Here is an example"
        Events = newevent_show_stimulus(Events,85,1,locx,locy+100,start_time,'screenshot_no','clear_no'); %press spacebar to continue
        
        responsestruct = CreateResponseStruct;
        
        responsestruct.x = locx;
        responsestruct.y = locy;
        
        responsestruct.allowedchars = KbName('Space');
        
        Events = newevent_keyboard(Events,start_time,responsestruct);
        
        Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval,'screenshot_no','clear_yes'); %fixation cross
        
        for ex_tar1 = 90:95
            ex_time1 = ex_tar1 - 89;
            Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,ex_tar1,1,target_loc_left,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,ex_tar1+10,1,target_loc_right,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
        end
        
        for ex_tar1 = 97:99
            ex_time1 = ex_tar1 - 90;
            Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,ex_tar1,1,target_loc_left,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
            if ex_tar1 == 97; %insert second target
                Events = newevent_show_stimulus(Events,106,1,target_loc_right,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
            else
                Events = newevent_show_stimulus(Events,ex_tar1+10,1,target_loc_right,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
            end
        end
        
        for ex_tar1 = 90:94
            ex_time1 = ex_tar1 - 81;
            Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,ex_tar1,1,target_loc_left,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,ex_tar1+10,1,target_loc_right,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
        end
        
        for ex_tar1 = 97:99
            ex_time1 = ex_tar1 - 83;
            Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,ex_tar1,1,target_loc_left,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,ex_tar1+10,1,target_loc_right,locy,disp_time + time_interval * ex_time1,'screenshot_no','clear_no');
        end
        
        %Responsestruct
        responsestruct = CreateResponseStruct;
        responsestruct.x = locx;
        responsestruct.y = locy;
        
        object_question_time1 = disp_time + (time_interval*17);
        
        %What object did you see?
        Events = newevent_show_stimulus(Events,84,1,locx,locy,object_question_time1,'screenshot_no','clear_yes');
        
        object_answer_time1 = object_question_time1 + .01;
        
        %Word Responsestruct
        responsestruct = CreateResponseStruct;
        
        responsestruct.showinput = 1;
        
        responsestruct.x = locx - 100;
        responsestruct.y = locy + 100;
        
        responsestruct.maxlength = 50;
        
        responsestruct.minlength = 3;
        
        responsestruct.allowbackspace = 1;
        
        responsestruct.waitforenter = 1;
        
        allowed = [];
        for letter = 'abcdefghijklmnopqrstuvwxyz'
            allowed = [allowed KbName(letter)];
        end
        
        responsestruct.allowedchars = [allowed KbName('Space')];
        
        [Events,reported_object1] = newevent_keyboard(Events,object_answer_time1,responsestruct);
        
        object_question_time2 = object_answer_time1 + .01;
        
        %What's the second target object you saw?
        Events = newevent_show_stimulus(Events,84,5,locx,locy,object_question_time2,'screenshot_no','clear_yes');
        
        object_answer_time2 = object_question_time2 + .01;
        
        %Word Responsestruct
        responsestruct = CreateResponseStruct;
        responsestruct.showinput = 1;
        responsestruct.x = locx - 100;
        responsestruct.y = locy + 100;
        responsestruct.maxlength = 50;
        responsestruct.minlength = 3;
        responsestruct.allowbackspace = 1;
        responsestruct.waitforenter = 1;
        allowed = [];
        for letter = 'abcdefghijklmnopqrstuvwxyz'
            allowed = [allowed KbName(letter)];
        end
        responsestruct.allowedchars = [allowed KbName('Space')];
        
        [Events,reported_object2] = newevent_keyboard(Events,object_answer_time2,responsestruct);
        
        %Feedback
        feedback_time = object_answer_time2 + .01;
        
        Events = newevent_show_stimulus(Events,95,1,target_loc_left,locy,feedback_time,'screenshot_no','clear_yes'); %probed target 1
        Events = newevent_show_stimulus(Events,106,1,target_loc_right,locy+250,feedback_time,'screenshot_no','clear_no'); %probed target 2
        Events = newevent_show_stimulus(Events,86,2,locx,locy-250,feedback_time,'screenshot_no','clear_no'); %displayed category
        Events = newevent_show_stimulus(Events,86,1,locx,locy-165,feedback_time,'screenshot_no','clear_no'); %displayed targets (feedback)
        
        %End trial
        end_time = feedback_time + 1;
        
        
    elseif Trial == 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Example Trial 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        time_interval = .3;
        
        %Fixation Cross
        Events = newevent_show_stimulus(Events,82,1,locx,locy,fixation_time,'screenshot_no','clear_yes');
        
        Events = newevent_show_stimulus(Events,86,3,locx,locy-50,start_time,'screenshot_no','clear_yes'); %Example category
        Events = newevent_show_stimulus(Events,87,7,locx,locy-300,start_time,'screenshot_no','clear_no'); %"Here is an example"
        Events = newevent_show_stimulus(Events,85,1,locx,locy+50,start_time,'screenshot_no','clear_no'); %Press Spacebar when ready
        
        responsestruct = CreateResponseStruct;
        
        responsestruct.x = locx;
        responsestruct.y = locy;
        
        responsestruct.allowedchars = KbName('Space');
        
        Events = newevent_keyboard(Events,start_time,responsestruct);
        
        Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval,'screenshot_no','clear_yes'); %fixation cross
        
        for ex_tar2 = 110:118
            ex_time2 = ex_tar2 - 109;
            Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval * ex_time2,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,ex_tar2,1,target_loc_left,locy,disp_time + time_interval * ex_time2,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,ex_tar2+10,1,target_loc_right,locy,disp_time + time_interval * ex_time2,'screenshot_no','clear_no');
        end
        
        for ex_tar2 = 110:117
            ex_time2 = ex_tar2 - 100;
            Events = newevent_show_stimulus(Events,82,1,locx,locy,disp_time + time_interval * ex_time2,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,ex_tar2,1,target_loc_left,locy,disp_time + time_interval * ex_time2,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,ex_tar2+10,1,target_loc_right,locy,disp_time + time_interval * ex_time2,'screenshot_no','clear_no');
        end
        
        %Responsestruct
        responsestruct = CreateResponseStruct;
        responsestruct.x = locx;
        responsestruct.y = locy;
        
        object_question_time1 = disp_time + (time_interval*17);
        
        %What's the first target object you saw?
        Events = newevent_show_stimulus(Events,84,1,locx,locy,object_question_time1,'screenshot_no','clear_yes');
        
        object_answer_time1 = object_question_time1 + .01;
        
        %Word Responsestruct
        responsestruct = CreateResponseStruct;
        
        responsestruct.showinput = 1;
        
        responsestruct.x = locx - 100;
        responsestruct.y = locy + 100;
        
        responsestruct.maxlength = 50;
        
        responsestruct.minlength = 3;
        
        responsestruct.allowbackspace = 1;
        
        responsestruct.waitforenter = 1;
        
        allowed = [];
        for letter = 'abcdefghijklmnopqrstuvwxyz'
            allowed = [allowed KbName(letter)];
        end
        
        responsestruct.allowedchars = [allowed KbName('Space')];
        
        [Events,reported_object1] = newevent_keyboard(Events,object_answer_time1,responsestruct);
        
        object_question_time2 = object_answer_time1 + .01;
        
        %What's the second target object you saw?
        Events = newevent_show_stimulus(Events,84,5,locx,locy,object_question_time2,'screenshot_no','clear_yes');
        
        object_answer_time2 = object_question_time2 + .01;
        
        %Word Responsestruct
        responsestruct = CreateResponseStruct;
        
        responsestruct.showinput = 1;
        
        responsestruct.x = locx - 100;
        responsestruct.y = locy + 100;
        
        responsestruct.maxlength = 50;
        
        responsestruct.minlength = 3;
        
        responsestruct.allowbackspace = 1;
        
        responsestruct.waitforenter = 1;
        
        allowed = [];
        for letter = 'abcdefghijklmnopqrstuvwxyz'
            allowed = [allowed KbName(letter)];
        end
        
        responsestruct.allowedchars = [allowed KbName('Space')];
        
        [Events,reported_object2] = newevent_keyboard(Events,object_answer_time2,responsestruct);
        
        %Feedback
        feedback_time = object_answer_time2 + .01;
        
        Events = newevent_show_stimulus(Events,118,1,target_loc_left,locy,feedback_time,'screenshot_no','clear_yes'); %probed target
        Events = newevent_show_stimulus(Events,86,3,locx,locy-250,feedback_time,'screenshot_no','clear_no'); %displayed category
        Events = newevent_show_stimulus(Events,86,1,locx,locy-165,feedback_time,'screenshot_no','clear_no'); %displayed targets (feedback)
        
        continue_time = feedback_time + 1;
        
        Events = newevent_show_stimulus(Events,85,2,locx,locy,continue_time,'screenshot_no','clear_yes'); %end of practice trials
        
        %End trial
        end_time = continue_time + 1;
    end
    
    Events = newevent_end_trial(Events,end_time);
    
elseif strcmp(Modeflag,'EndTrial');
    if Parameters.disableinput == 0;
        if Trial >=2
            Trial_Export.first_target_response = char(Events.response{reported_object1});
            Trial_Export.second_target_response = char(Events.response{reported_object2});
        else
            Trial_Export.first_target_response = 0;
            Trial_Export.second_target_response = 0;
        end
    end
elseif strcmp(Modeflag,'EndBlock');
else   %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end