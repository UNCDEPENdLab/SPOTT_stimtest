clear all
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

select_rand_combo_row = randperm(28); %shuffled array of 1 to 28

left_stim(Trial) = shuffled_stim_array(select_rand_combo_row,1);
right_stim(Trial) = shuffled_stim_array(select_rand_combo_row,2);

keyboard