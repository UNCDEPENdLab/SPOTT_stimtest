function [Events Parameters Stimuli_sets Block_Export Trial_Export Numtrials] = Demo(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, Events, Block_Export, Trial_Export, Demodata)
load('blockvars')
KbName('UnifyKeyNames');
if IsOSX | IsLinux; sep = '/'; else sep = '\'; end %slash direction based on OS
if strcmp(Modeflag,'InitializeBlock');
    clear Stimuli_sets
    %Fixation Cross & Instructions
    instructions = 1;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'On each trial, you will be presented with two items,','both of which will be an item from the experiment','you just completed: either a deck or a carny.','Your job is to determine which item between','the two is more likely to win you points.','You will answer using the LEFT & RIGHT ARROW KEYS.','Press Spacebar when you''re ready to proceed.'};
    stimstruct.wrapat = 70;
    stimstruct.vSpacing = 3;
    stimstruct.stimsize = 25;
    Stimuli_sets(instructions) = Preparestimuli(Parameters,stimstruct);
    
    %"Which item on screen may award you more points?"
    resp_instruct = 2;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Which item on screen may award you more points?','Your choice:'};
    stimstruct.stimsize = 25;
    Stimuli_sets(resp_instruct) = Preparestimuli(Parameters,stimstruct);
    
    %Faces & Decks
    stim = 6;
    stim_dir_name = sprintf('Stimuli%sstim',sep);
    stim_dir = dir(stim_dir_name);
    stimstruct = CreateStimStruct('image');
    scale = 1.7;
    subject.pavfacescale = 0.43/scale; %resize factor for images in each phase
    subject.pavdeckscale = 0.58/scale;
    for x = 1:length(stim_dir)-2;
        stimstruct.stimuli{x} = sprintf('stim%s%s',sep,stim_dir(x+2).name);
        if strcmpi(stim_dir(x+2).name(1:4),'Rafd')
            stimstruct.stimsize(x) = subject.pavfacescale;
        elseif strcmpi(stim_dir(x+2).name(end-13:end-4),'dropshadow')
            stimstruct.stimsize(x) = subject.pavdeckscale;
        else
            sca
            keyboard
        end
    end
    Stimuli_sets(stim) = Preparestimuli(Parameters,stimstruct);
    
    %Response Keys
    key = 10;
    key_dir_name = sprintf('Stimuli%skeys',sep);
    key_dir = dir(key_dir_name);
    stimstruct = CreateStimStruct('image');
    for x = 1:length(key_dir)-2;
        stimstruct.stimuli{x} = sprintf('keys%s%s',sep,key_dir(x+2).name);
    end
    Stimuli_sets(key) = Preparestimuli(Parameters,stimstruct);
    
    %Highlight Response Box
    highlight = 20;
    stimstruct = CreateStimStruct('shape');
    stimstruct.stimuli = {'FrameRect'};
    stimstruct.color = [255,255,255];
    rect_size = 250;
    stimstruct.xdim = rect_size;
    stimstruct.ydim = rect_size;
    stimstruct.linewidth = 5;
    Stimuli_sets(highlight) = Preparestimuli(Parameters,stimstruct);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Calculate dual array of unique stim combinations
    num_stim = 8;
    num_indiv_combos = num_stim - 1;
    insert_stim_index = 0;
    for first_stim_num = 1:num_indiv_combos
        second_stim_num = first_stim_num;
        include_combo = 1;
        while include_combo == 1
            second_stim_num = second_stim_num + 1;
            if second_stim_num <= num_stim
                insert_stim_index = insert_stim_index + 1;
                first_stim_num_array(insert_stim_index) = first_stim_num;
                second_stim_num_array(insert_stim_index) = second_stim_num;
            else
                include_combo = 0;
            end
        end
    end
    stim_array(:,1) = first_stim_num_array';
    stim_array(:,2) = second_stim_num_array';
    for shuff_row_num = 1:length(stim_array(:,1))
        shuffled_row = Shuffle(stim_array(shuff_row_num,:));
        shuffled_stim_array(shuff_row_num,:) = shuffled_row;
    end
    rand_combo_array = randperm(28); %shuffled array of 1 to 28
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Numtrials = length(rand_combo_array); %28
    
elseif strcmp(Modeflag,'InitializeTrial');
    
    %Select stim nums
    left_stims(Trial) = shuffled_stim_array(rand_combo_array(Trial),1);
    right_stims(Trial) = shuffled_stim_array(rand_combo_array(Trial),2);
    left_stim = left_stims(Trial);
    right_stim = right_stims(Trial);
    
    %Record stim names
    left_stim_name = stim_dir(left_stim+2).name;
    right_stim_name = stim_dir(right_stim+2).name;
    
    %%Location values%%
    
    %Center location of screen
    centerx = Parameters.centerx;
    centery = Parameters.centery;
    
    %Screen size
    sx = Parameters.ScreenResolutionX;
    sy = Parameters.ScreenResolutionY;
    
    %Areas of the screen
    y_spacing = 125;
    y_offset = 100;
    face_y = centery - y_spacing + y_offset;
    button_y = centery + y_spacing + y_offset;
    resp_instruct_y = centery - 300;
    x_spacing = 200;
    left_x = centerx - x_spacing;
    right_x = centerx + x_spacing;
    
    %Timing Variables
    instruction_time = 0.1;
    feedback_time = 0.1;
    if Trial == 1
        response_time = instruction_time + 0.01;
    elseif Trial >=2 && Trial <= 5
        response_time = feedback_time + 3;
    else
        response_time = feedback_time + 1;
    end
    end_time = response_time + 0.01;
    
    %Instructions
    if Trial == 1
        next_line = 1;
        clear_screen = 'clear_yes';
        start_line_y = 0;
        screenbottom_offset = 100;
        end_line_y = sy - screenbottom_offset;
        line_y = start_line_y;
        instruct_length = length(Stimuli_sets(instructions).stimnames);
        for next_line = 1:instruct_length
            line_y = line_y + (end_line_y/instruct_length);
            Events = newevent_show_stimulus(Events,instructions,next_line,centerx,line_y,instruction_time,'screenshot_no',clear_screen); %instructions
            clear_screen = 'clear_no';
        end
        responsestruct = CreateResponseStruct;
        responsestruct.x = centerx;
        responsestruct.y = centery;
        responsestruct.allowedchars = KbName('Space');
        Events = newevent_keyboard2(Events,instruction_time,responsestruct);
    elseif Trial > 1
        %Feedback (from previous trial)
        if strcmpi(response_text,'L')
            Events = newevent_show_stimulus(Events,stim,left_stims(Trial-1),left_x,face_y,feedback_time,'screenshot_no','clear_yes'); %left stim
            Events = newevent_show_stimulus(Events,highlight,1,left_x,face_y,feedback_time,'screenshot_no','clear_no'); %left highlight box
            Events = newevent_show_stimulus(Events,resp_instruct,2,left_x,centery-200,feedback_time,'screenshot_no','clear_no'); %"Your choice:"
        elseif strcmpi(response_text,'R')
            Events = newevent_show_stimulus(Events,stim,right_stims(Trial-1),right_x,face_y,feedback_time,'screenshot_no','clear_yes'); %right stim
            Events = newevent_show_stimulus(Events,highlight,1,right_x,face_y,feedback_time,'screenshot_no','clear_no'); %right highlight box
            Events = newevent_show_stimulus(Events,resp_instruct,2,right_x,centery-200,feedback_time,'screenshot_no','clear_no'); %"Your choice:"
        end
    end
    
    %Response Instructions (on every trial)
    Events = newevent_show_stimulus(Events,resp_instruct,1,centerx,resp_instruct_y,response_time,'screenshot_no','clear_yes'); %"Which item on screen may award you more points?"
    
    %Faces/Decks & Buttons
    Events = newevent_show_stimulus(Events,stim,left_stim,left_x,face_y,response_time,'screenshot_no','clear_no'); %left stim
    Events = newevent_show_stimulus(Events,stim,right_stim,right_x,face_y,response_time,'screenshot_no','clear_no'); %right stim
    left_key = 1; right_key = 2;
    Events = newevent_show_stimulus(Events,key,left_key,left_x,button_y,response_time,'screenshot_no','clear_no'); %left key
    Events = newevent_show_stimulus(Events,key,right_key,right_x,button_y,response_time,'screenshot_no','clear_no'); %right key
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.showinput = 0;
    responsestruct.x = centerx;
    responsestruct.y = centery;
    responsestruct.maxlength = 1;
    responsestruct.minlength = 1;
    responsestruct.allowbackspace = 0;
    responsestruct.waitforenter = 0;
    allowed = [KbName('LeftArrow') KbName('RightArrow')];
    responsestruct.allowedchars = allowed;
    [Events,response_event] = newevent_keyboard(Events,response_time,responsestruct);
    
    %Ends trial
    Events = newevent_end_trial(Events,end_time);
    
elseif strcmp(Modeflag,'EndTrial');
    Trial_Export.left_stim = left_stim_name;
    Trial_Export.right_stim = right_stim_name;
    response_text = char(Events.response{response_event});
    Trial_Export.response = response_text;
elseif strcmp(Modeflag,'EndBlock');
    %Present a farewell message
    briefmessage(Parameters,'This concludes the science.','Thank you for participating!','Arial',44,0,0,1.5);
else   %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end