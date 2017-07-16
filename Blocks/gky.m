function [Events Parameters Stimuli_sets Block_Export Trial_Export Numtrials] = Demo(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, Events, Block_Export, Trial_Export, Demodata)
load('blockvars')
KbName('UnifyKeyNames');
if IsOSX | IsLinux; sep = '/'; else sep = '\'; end %slash direction based on OS
if strcmp(Modeflag,'InitializeBlock');    
    clear Stimuli_sets    
    %Fixation Cross & Instructions
    ins = 1;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'+','At the beginning of each trial, you''ll be given a category.','Once you start the trial, a stream of images will display.','Keep your eyes on the fixation cross and','try to detect objects that fit the category.','Either one or two target objects will','appear within the stream of images.','Report the objects in the order you saw them.','If you only saw one target object,','type in "Nothing" when asked to report the second target object.','Press the Spacebar when you''re ready to begin.'};
    stimstruct.wrapat = 70;
    stimstruct.vSpacing = 3;
    stimstruct.stimsize = 25;
    Stimuli_sets(ins) = Preparestimuli(Parameters,stimstruct);
    
    %Prompts
    prompts = 2;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Rate this image from 1-7:','Your partner rated this image:','Rate how close you feel to your partner','Here''s your partner''s rating of closeness to you:'};
    stimstruct.wrapat = 70;
    stimstruct.stimsize = 50;
    Stimuli_sets(prompts) = Preparestimuli(Parameters,stimstruct);
    
    %"Press Spacebar When Ready"
    spacebar = 3;
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'(Press Spacebar when ready)'};
    stimstruct.stimsize = 25;
    Stimuli_sets(spacebar) = Preparestimuli(Parameters,stimstruct);
    
    %Faces & Decks
    stim = 6;
    stim_dir_name = sprintf('Stimuli%s',sep);
    stim_dir = dir(stim_dir_name);
    stimstruct = CreateStimStruct('image');
    for x = 1:length(stim_dir)-2;
        stimstruct.stimuli{x} = sprintf('%s',stim_dir(x+2).name);
    end
    stimstruct.stimsize = 0.5;
    Stimuli_sets(stim) = Preparestimuli(Parameters,stimstruct);
 
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
Numtrials = (num_stim*num_indiv_combos)/2;

elseif strcmp(Modeflag,'InitializeTrial');
    
    %Select stim nums
    left_stim(Trial) = shuffled_stim_array(rand_combo_array(Trial),1);
    right_stim(Trial) = shuffled_stim_array(rand_combo_array(Trial),2);
    
    %%Location values%%
    
    %Center location of screen
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    %Top & bottom areas of the screen
    top = locy - 200;
    bottom = locy + 200;
    
    %Partner picture location
    partner_locx = locx;
    partner_locy = locy - 400;
    
    %Timing Variables
    instruction_time = 0;
    disp_time = instruction_time + .01;
    end_time = partner_closeness_time + 3;
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.x = locx;
    responsestruct.y = locy;
    
    Events = newevent_show_stimulus(Events,stim,stim+left_stim,locx,top,disp_time,'screenshot_no','clear_yes'); %rate this image
    Events = newevent_show_stimulus(Events,stim,stim+right_stim,locx,locy,disp_time,'screenshot_no','clear_no'); %image
        
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.showinput = 1;
    responsestruct.x = locx;
    responsestruct.y = bottom;
    responsestruct.maxlength = 1;
    responsestruct.minlength = 1;
    responsestruct.allowbackspace = 1;
    responsestruct.waitforenter = 1;
    allowed = [];
    for number = '1234567'
        allowed = [allowed KbName(number)];
    end
    responsestruct.allowedchars = allowed;
    [Events,item_rate] = newevent_keyboard(Events,disp_time,responsestruct);
    
    partner_item_rate = randi(7); %random for now
    
    Events = newevent_show_stimulus(Events,prompts,2,locx,top,partner_rate_time,'screenshot_no','clear_yes'); %your partner's item rating
    Events = newevent_show_stimulus(Events,partner_rating,partner_item_rate,locx,bottom,partner_rate_time,'screenshot_no','clear_no'); %rating number
    Events = newevent_show_stimulus(Events,partner,1,partner_locx,partner_locy,partner_rate_time,'screenshot_no','clear_no'); %partner pic
    Events = newevent_show_stimulus(Events,stim,Trial,locx,locy,partner_rate_time,'screenshot_no','clear_no'); %image
    
    Events = newevent_show_stimulus(Events,prompts,3,locx,locy,closeness_time,'screenshot_no','clear_yes'); %how close do you feel to your partner?
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.showinput = 1;
    responsestruct.x = locx;
    responsestruct.y = bottom;
    responsestruct.maxlength = 1;
    responsestruct.minlength = 1;
    responsestruct.allowbackspace = 1;
    responsestruct.waitforenter = 1;
    allowed = [];
    for number = '1234567'
        allowed = [allowed KbName(number)];
    end
    responsestruct.allowedchars = allowed;
    [Events,partner_rate] = newevent_keyboard(Events,closeness_time,responsestruct);
    
    partner_closeness_rate = randi(7); %random for now
    
    Events = newevent_show_stimulus(Events,prompts,4,locx,top,partner_closeness_time,'screenshot_no','clear_yes'); %how close your partner feels to you
    Events = newevent_show_stimulus(Events,partner_rating,partner_closeness_rate,locx,locy,partner_closeness_time,'screenshot_no','clear_no'); %rating number
    Events = newevent_show_stimulus(Events,partner,1,partner_locx,partner_locy,partner_closeness_time,'screenshot_no','clear_no'); %partner pic
    
    %Ends trial
    Events = newevent_end_trial(Events,end_time);
    
elseif strcmp(Modeflag,'EndTrial');
    if Parameters.disableinput == 0;
        Trial_Export.subjects_item_rate = char(Events.response{item_rate});
        Trial_Export.subjects_partner_rate = char(Events.response{partner_rate});
        Trial_Export.partners_item_rate = partner_item_rate;
        Trial_Export.partners_subject_rate = partner_closeness_rate;
    end
elseif strcmp(Modeflag,'EndBlock');
else   %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end