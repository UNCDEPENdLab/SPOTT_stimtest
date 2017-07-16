function [Events Parameters Stimuli_sets Block_Export Trial_Export Numtrials] = Demo(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, Events, Block_Export, Trial_Export, Demodata)
load('blockvars')
if strcmp(Modeflag,'InitializeBlock');
    
    category_names = {'Art supply';'Bird';'Body part';'Dessert';'Dinner food';'Four-footed animal';'Fruit';'Furniture';'Kitchenware';'Musical instrument';'Office equipment';'Sports equipment';'Toy';'Vegetable';'Vehicle';'Weapon'};
    
    %Targets
    stimstruct = CreateStimStruct('image');
    for targ_set = 1:length(category_names);
        for x = 1 : 24
            cat = category_names{targ_set};
            stim_dir = dir(sprintf('Stimuli/%s',cat));
            stimstruct.stimuli{x} = sprintf('%s/%s',cat,stim_dir(x+2).name);
        end
        Stimuli_sets(targ_set) = Preparestimuli(Parameters,stimstruct);
    end
    
    %Category Names
    stimstruct = CreateStimStruct('text');
    for cat_set = 1:length(category_names)
        stimstruct.stimuli = category_names(cat_set);
        stimstruct.stimsize = 50;
        Stimuli_sets(targ_set+cat_set) = Preparestimuli(Parameters,stimstruct);
    end
    
    %Distractors
    stimstruct = CreateStimStruct('image');
    dist_dir = dir('Stimuli/Distractors');
    numdist = length(dist_dir) - 2;
    
    %Find the image distractor numbers (in parenthesis)
    for dist = 1: numdist
        distractor_names{dist} = sprintf('Distractors/%s',dist_dir(dist+2).name);
        distractor_nums(dist) = str2num(distractor_names{dist}(25:end-5));
        distractor_reverse_index(distractor_nums(dist)) = dist;
        stimstruct.stimuli{dist} =  distractor_names{dist};
    end
    dist_set = targ_set+cat_set+1; %33
    distractor_category = dist_set;
    Stimuli_sets(dist_set) = Preparestimuli(Parameters,stimstruct);
    
    distractors = distractor_nums;  %set of image distractor numbers  (in parenthesis, e.g. "125" of "distractor (125)")
    
    %Excluded Distractors per Category
    excluded_dist = csvread('cat_eeg-distractors.csv');
    
    %Find the distractors that shouldn't be excluded per target category
    good_dist = 0;
    good_dists =[];
    for cat_num = 1:length(category_names)  %for each category
        for num_dist = 1:length(distractors) %for each distractor
            distractormatch = distractors(num_dist) == excluded_dist(:,cat_num);
            if(max(distractormatch) ==0)
                good_dist = good_dist + 1;
                good_dists{cat_num}(good_dist) = distractors(num_dist);
            end
        end
        good_dist = 0;
    end
    
    other_sets = dist_set+1; %34
    
    %Fixation Cross & Instructions
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'+','A category will display on the screen for a brief time,','followed by a stream of images. Keep your eyes on the fixation cross','and try to detect an object that fits that category.','A symbol will also appear at the end of the trial; either "," or "."','You will be asked to report the object and the symbol.','Make sure to keep your chin on the chin rest at all times.','Press the Spacebar to continue to the experiment.'};
    stimstruct.wrapat = 70;
    stimstruct.vSpacing = 3;
    stimstruct.stimsize = 25;
    Stimuli_sets(other_sets) = Preparestimuli(Parameters,stimstruct); %34
    
    %Questions & Symbols
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'.',',','Type the object you saw that fit the category and then hit Enter. If you did not see the object, type the word "nothing".','What symbol did you see?'};
    stimstruct.wrapat = 70;
    stimstruct.stimsize = 50;
    Stimuli_sets(other_sets+1) = Preparestimuli(Parameters,stimstruct); %35
    
    %Questions
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'What object did you see?','What symbol did you see?','Displayed stimuli:' 'Press Spacebar when ready'};
    stimstruct.stimsize = 50;
    Stimuli_sets(other_sets+2) = Preparestimuli(Parameters,stimstruct); %36
    
    %Press Spacebar When Ready
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'(Press Spacebar when ready)','Now time for the real thing! Press Spacebar when ready'};
    stimstruct.stimsize = 25;
    Stimuli_sets(other_sets+3) = Preparestimuli(Parameters,stimstruct); %37
    
    %Displayed Targets (Feedback)
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Displayed Target:','Clothing','Plumbing','Now things will speed up!','Here is an example trial'};
    stimstruct.stimsize = 50;
    Stimuli_sets(other_sets+4) = Preparestimuli(Parameters,stimstruct); %38
    
    %Instructions
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'That trial only displayed one object that fit the category.','When you only see one object that fits the displayed category,','type "nothing" when asked about a second object.','If you are confused about any of the instructions,','ask the researcher to help explain before you begin.','Press Spacebar when you are ready to continue to the main experiment','Here is another example trial, but faster!'};
    stimstruct.stimsize = 25;
    Stimuli_sets(other_sets+5) = Preparestimuli(Parameters,stimstruct); %39
    
    %Breaktime!
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'You''ve earned a break!','Press Spacebar when you''re ready to continue.','You''ve earned yourself a random post from Yik Yak:','"Every kiss begins with k" I whisper to myself as I read the one letter reply from my crush.','My GPA is so low it''s got boots with the fur.','[grabs Walmart intercom] IF DIGIORNOS ISN''T DELIVERY THEN HOW IS IT DELIVERED TO THE STORE!? *fighting noises* DELIVER US THE TRUTH','When you get your burrito back and they didn''t fold it properly. And forgot the meat. And the beans. And the guac. And the tortilla. It''s made of paper. It''s your midterm. You failed.','"Mom? Don''t freak out, but I''m in the hospital." "Jeremy, you have been a doctor for 8 years now, please stop starting every phone conversation we have with that."','When life''s got you down, just think of the kid who was cut from the basketball team in Air Bud to make room for a golden retriever.','According to this box of mac and cheese, I''m a family of four'};
    stimstruct.stimsize = 25;
    Stimuli_sets(other_sets+6) = Preparestimuli(Parameters,stimstruct); %40
    
    %Jokes
    stimstruct = CreateStimStruct('image');

    
    Numtrials = 192; %8 blocks of 24 trials
    numblocks = Numtrials/24;
    
    %Start sending EEG markers
    sendmarkerwpause(Parameters,Parameters.MARKERS.BEGINBLOCK);
    
    %Make sure symbols are shown only 1/3 of trials
    symbol_chance = [ones(ceil(Numtrials/3),1);zeros(Numtrials- ceil(Numtrials/3),1)];
    symbol_chance = Shuffle(symbol_chance);
    
    %Bad FT cats for each target cat
    art_supply_rejects = [0];
    bird_rejects = [5];
    body_part_rejects = [1 4 5 7 8 9 10 11 12 13 16];
    dessert_rejects = [5];
    dinner_rejects = [4 7 14];
    four_footed_rejects = [13];
    fruit_rejects = [14];
    furniture_rejects = [9 11];
    kitchen_rejects = [4 5 7 14];
    music_rejects = [0];
    office_rejects = [1 8];
    sports_rejects = [0];
    toy_rejects = [1 10 12 16];
    vegetable_rejects = [7];
    vehicle_rejects = [0];
    weapon_rejects = [12];
    
    all_rejects = {art_supply_rejects,bird_rejects,body_part_rejects,dessert_rejects,dinner_rejects,four_footed_rejects,fruit_rejects,furniture_rejects,kitchen_rejects,music_rejects,office_rejects,sports_rejects,toy_rejects,vegetable_rejects,vehicle_rejects,weapon_rejects};
    
    %Choose targ cats and FT cats
    c = 1:16;
    shuff_cats = Shuffle(c);
    excl_check = 1;
    
    %Reshuffle until targ cats don't align with FT cats
    while excl_check <= 8;
        targ_cats(excl_check) = shuff_cats(excl_check);
        ft_cats(excl_check) = shuff_cats(excl_check+8);
        
        current_rejects = all_rejects{excl_check};
        
        for r = 1:length(current_rejects)
            if targ_cats(excl_check) == current_rejects(r)
                shuff_cats = Shuffle(c);
                excl_check = 0;
                break
            end
        end
        excl_check = excl_check + 1;
    end
    
    current_cat = 1;
    
    which_targ = 0;
    
    target_sequence = [Shuffle(1:24)];
    
    %     joke = 2;
    
elseif strcmp(Modeflag,'InitializeTrial');
    
    if Trial == 1
        Trial_Export.target_sequence = target_sequence;
    end
    
    %Center location of screen
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    %SEND EEG Triggers over the Parallel Port
    sendmarkerwpause(Parameters,Parameters.MARKERS.BEGINTRIAL);
    third=floor(Trial/100); % For EEG triggers the leftmost digit
    second=floor(Trial/10-third*10);
    first=Trial-second*10-third*100;
    
    %Which Trial Number
    sendmarkerwpause(Parameters,Parameters.MARKERS.FIRSTDIGIT_TRIALNUM+third);
    sendmarkerwpause(Parameters,Parameters.MARKERS.INTERVENE);
    sendmarkerwpause(Parameters,Parameters.MARKERS.SECONDDIGIT_TRIALNUM+second);
    sendmarkerwpause(Parameters,Parameters.MARKERS.INTERVENE);
    sendmarkerwpause(Parameters,Parameters.MARKERS.THIRDDIGIT_TRIALNUM+first);
    
    %Randomizes location of target & false target
    which_targ_loc = randi(2);
    which_falsetarg_loc = 2 - which_targ_loc + 1;
    
    Parameters.slowmotionfactor = 1;
    
    %False Target
    which_falsetarg = randi(24);
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.WHICHFALSETARG + which_falsetarg - 1); %EEG marker for which false target's displayed
    
    target_category = targ_cats(current_cat);
    ft_category = ft_cats(current_cat);
    
    current_good_dists = good_dists{target_category};  %gather the good distractors for this category
    current_good_dists = Shuffle(current_good_dists);  %scramble the order
    shuff_dists = current_good_dists(1:50);  %now we will need to translate these into stimulus numbers
    safe_distractors = distractor_reverse_index(shuff_dists);
    
    first_block = randi(6)+4; %5 to 10 distractors b4 targ or FT
    second_block = randi(6)+14; %15 to 20 distractors b4 targ or FT
    both_blocks = [first_block,second_block];
    shuff_block = Shuffle(both_blocks); %shuffle the time blocks
    
    %How many distractors will display before the target (either first or second block)
    dist_b4_targ = shuff_block(1);
    
    %How many distractors will display before false target (either first or second block)
    dist_b4_falsetarg = shuff_block(2);
    
    %Target time block (used for EEG marker)
    if dist_b4_targ < dist_b4_falsetarg
        block = 1;
    else
        block = 2;
    end
    
    %Location Values
    loc_left = locx - 275;
    loc_right = locx + 275;
    loc_left = locx - 200;
    loc_right = locx + 200;
    
    %Timing Variables
    instruction_time = 0;
    start_time = 0;
    fixation_time = .2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%EEG%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sendmarkerwpause(Parameters,Parameters.MARKERS.CATEGORY + target_category - 1); %EEG marker for which category
    sendmarkerwpause(Parameters,Parameters.MARKERS.TARG_BLOCK + block); %EEG marker for which time block the target's in
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Experiment Display%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    which_targ = which_targ + 1;
    targ_shown = target_sequence(which_targ);
    
    %Goes to the next category after all targets in the current category have been shown
    next_cat = ~mod(Trial,(Numtrials/(Numtrials/numblocks)));
    
    if next_cat
        current_cat = current_cat + 1;
        which_targ = 1;
        target_sequence = Shuffle(1:24);
    end
    
    Trial_Export.target_sequence = target_sequence;
    
    if Trial == 1
        time_interval = .25;
    elseif Trial == 2
        time_interval = .2;
    elseif Trial == 3
        time_interval = .15;
    else
        time_interval = .1055;
    end
    
    disp_time = .72 - time_interval; %time when the images start to display after hitting spacebar
    
    fixation_time = .2; %time when the fixation cross appears
    
    %Fixation Cross
    Events = newevent_show_stimulus(Events,other_sets,1,locx,locy,fixation_time,'screenshot_no','clear_yes'); %fixation cross
    Events = newevent_ParallelPort_mark(Events,fixation_time,Parameters.MARKERS.FIXATION); %EEG marker for fixation cross
    
    Trial_Export.which_targ = targ_shown;
    Trial_Export.which_targ_category = current_cat;
    
    %Category
    Events = newevent_show_stimulus(Events,target_category+targ_set,1,locx,locy-25,start_time,'screenshot_no','clear_yes');
    Events = newevent_show_stimulus(Events,other_sets+3,1,locx,locy+75,start_time,'screenshot_no','clear_no');
    responsestruct = CreateResponseStruct;
    responsestruct.x = locx;
    responsestruct.y = locy;
    responsestruct.allowedchars = KbName('Space');
    Events = newevent_keyboard(Events,start_time,responsestruct);
    
    %Chooses timing of target based on how many distractors are presented before target
    pre_target_time = disp_time + time_interval * (dist_b4_targ + 1);
    
    %Choose timing of false target " " " " " " " " "
    pre_falsetarg_time = disp_time + time_interval * (dist_b4_falsetarg + 1);
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.FALSETARGTIME + dist_b4_falsetarg - 15); %EEG marker for false target time
    
    %Distractors (with target)
    for dist_index = 1:25;
        Events = newevent_show_stimulus(Events,other_sets,1,locx,locy,disp_time + time_interval * dist_index,'screenshot_no','clear_yes'); %fixation cross
        Events = newevent_show_stimulus(Events,distractor_category,safe_distractors(dist_index),loc_left,locy,disp_time + time_interval * dist_index,'screenshot_no','clear_no'); %distractors (left)
        Events = newevent_show_stimulus(Events,distractor_category,safe_distractors(dist_index+25),loc_right,locy,disp_time + time_interval * dist_index,'screenshot_no','clear_no'); %distractors (right)
        if (((disp_time + time_interval * dist_index) ~= pre_target_time) && ((disp_time + time_interval * dist_index) ~= pre_falsetarg_time))
            Events =  newevent_ParallelPort_mark(Events,disp_time + time_interval * dist_index,Parameters.MARKERS.NN); %EEG marker for neutral-neutral
        end
    end
    
    %Target (either left or right)
    if which_targ_loc == 1
        Events = newevent_show_stimulus(Events,target_category,targ_shown,loc_left,locy,pre_target_time,'screenshot_no','clear_no'); %target
        if pre_target_time ~= pre_falsetarg_time
            Events =  newevent_ParallelPort_mark(Events,pre_target_time,Parameters.MARKERS.TN); %EEG marker for target-neutral
        end
    else
        Events = newevent_show_stimulus(Events,target_category,targ_shown,loc_right,locy,pre_target_time,'screenshot_no','clear_no'); %target
        if pre_target_time ~= pre_falsetarg_time
            Events =  newevent_ParallelPort_mark(Events,pre_target_time,Parameters.MARKERS.NT); %EEG marker for neutral-target
        end
    end
    
    %False Target (either left or right)
    if which_falsetarg_loc == 1
        Events = newevent_show_stimulus(Events,ft_category,which_falsetarg,loc_left,locy,pre_falsetarg_time,'screenshot_no','clear_no'); %false target
        if pre_falsetarg_time == pre_target_time
            Events =  newevent_ParallelPort_mark(Events,pre_falsetarg_time,Parameters.MARKERS.FT); %EEG marker for false target-target
        else
            Events =  newevent_ParallelPort_mark(Events,pre_falsetarg_time,Parameters.MARKERS.FN); %EEG marker for false target-neutral
        end
    else
        Events = newevent_show_stimulus(Events,ft_category,which_falsetarg,loc_right,locy,pre_falsetarg_time,'screenshot_no','clear_no'); %false target
        if pre_falsetarg_time == pre_target_time
            Events =  newevent_ParallelPort_mark(Events,pre_falsetarg_time,Parameters.MARKERS.TF); %EEG marker for target-false target
        else
            Events =  newevent_ParallelPort_mark(Events,pre_falsetarg_time,Parameters.MARKERS.NF); %EEG marker for neutral-false target
        end
    end
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.FALSETARGSIDE + which_falsetarg_loc - 1); %EEG marker for what side false target appeared
    
    Trial_Export.false_target_category = ft_category;
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.FALSETARGCATEGORY + ft_category - 1); %EEG marker for which false target category
    
    Trial_Export.false_target = which_falsetarg;
    
    symbol_time = disp_time + time_interval * 26;
    
    post_pic_delay = rand*.5 +.7;
    
    if symbol_chance(Trial) == 1 %Display symbol on 1/3 of trials
        
        symbol = randi(2); %randomly chooses dot or comma
        Trial_Export.which_symbol = symbol;
        
        %Symbol display
        Events = newevent_show_stimulus(Events,other_sets,1,locx,locy,symbol_time,'screenshot_no','clear_yes'); %fixation cross
        Events = newevent_show_stimulus(Events,other_sets+1,symbol,locx,locy,symbol_time+post_pic_delay,'screenshot_no','clear_yes'); %symbol
        Events = newevent_ParallelPort_mark(Events,symbol_time+post_pic_delay,Parameters.MARKERS.WHICHSYMBOL + symbol - 1); %EEG marker for which symbol's displayed
        
        object_question_time = symbol_time + post_pic_delay + .01;
    else
        Events = newevent_blank(Events,symbol_time); %clears screen
        object_question_time = symbol_time + post_pic_delay;
    end
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.x = locx;
    responsestruct.y = locy;
    
    %What object did you see?
    Events = newevent_show_stimulus(Events,other_sets+2,1,locx,locy,object_question_time,'screenshot_no','clear_yes');
    
    object_answer_time = object_question_time + .01;
    
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
    
    [Events,reported_object] = newevent_keyboard(Events,object_answer_time,responsestruct);
    
    Events =  newevent_ParallelPort_mark(Events,object_answer_time,Parameters.MARKERS.OBJECTRESPONSE); %EEG marker for object response
    
    symbol_question_time = object_answer_time + .01;
    symbol_answer_time = symbol_question_time + .01;
    
    if symbol_chance(Trial) == 1
        %What symbol did you see?
        Events = newevent_show_stimulus(Events,other_sets+2,2,locx,locy,symbol_question_time,'screenshot_no','clear_yes');
        %Symbol Responsestruct
        responsestruct = CreateResponseStruct;
        responsestruct.showinput = 1;
        responsestruct.x = locx;
        responsestruct.y = locy+100;
        responsestruct.maxlength = 1;
        responsestruct.minlength = 1;
        responsestruct.fontsize = 65;
        responsestruct.allowbackspace = 1;
        responsestruct.waitforenter = 1;
        responsestruct.allowedchars = [KbName('.>'),KbName(',<')];
        [Events,symbol_response] = newevent_keyboard(Events,symbol_answer_time,responsestruct);
        Events =  newevent_ParallelPort_mark(Events,object_answer_time,Parameters.MARKERS.SYMBOLRESPONSE); %EEG marker for symbol response
    end
    
    %Feedback
    feedback_time = symbol_answer_time + .01;
    
    if which_targ_loc == 1
        Events = newevent_show_stimulus(Events,target_category,targ_shown,loc_left,locy,feedback_time,'screenshot_no','clear_yes'); %probed target
    else
        Events = newevent_show_stimulus(Events,target_category,targ_shown,loc_right,locy,feedback_time,'screenshot_no','clear_yes'); %probed target
    end
    
    if symbol_chance(Trial) == 1
        Events = newevent_show_stimulus(Events,other_sets+1,symbol,locx,locy,feedback_time,'screenshot_no','clear_no'); %Symbol feedback
    else
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %End trial
    end_time = feedback_time + 1;
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.TARGETSIDE + which_targ_loc - 1); %EEG marker for what side the target appeared
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.TARGETTIME + dist_b4_targ - 5); %EEG Marker for target time
    
    sendmarkerwpause(Parameters,Parameters.MARKERS.WHICHPIC + targ_shown - 1); %EEG marker for which target is shown
    
    %Is it break time?
    break_time = ~mod(Trial,Numtrials/(Numtrials/numblocks)); %last target trial of every category
    if break_time && Trial ~= Numtrials
        Events = newevent_show_stimulus(Events,40,1,locx,locy-100,end_time,'screenshot_no','clear_yes'); %take a break!
        Events = newevent_show_stimulus(Events,other_sets+6,2,locx,locy+100,end_time,'screenshot_no','clear_no'); %press spacebar
        %         joke = joke + 1;
        %         Events = newevent_show_stimulus(Events,other_sets+6,joke,locx,locy+200,end_time,'screenshot_no','clear_no'); %joke
        responsestruct = CreateResponseStruct;
        responsestruct.x = locx;
        responsestruct.y = locy;
        responsestruct.allowedchars = KbName('Space');
        Events = newevent_keyboard(Events,end_time+5,responsestruct);
        trial_end_time = end_time + 5.01;
        which_targ = 0;
    else
        trial_end_time = end_time;
    end
    
    Events = newevent_end_trial(Events,trial_end_time); %ends trial
    
elseif strcmp(Modeflag,'EndTrial');
    Trial_Export.object_response = char(Events.response{reported_object});
    try
        Trial_Export.symbol_response = char(Events.response{symbol_response});
    catch
        Trial_Export.symbol_response = 0;
    end
elseif strcmp(Modeflag,'EndBlock');
    %Present a farewell message
    briefmessage(Parameters,'This concludes the science.','Thank you for participating!','Arial',44,0,0,1.5);
    %EEG Trigger for the end of experiment
    sendmarkerwpause(Parameters,Parameters.MARKERS.ENDBLOCK);
else   %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end