allvars = who;

goldenvariables = {'Parameters', 'Stimuli_sets', 'Trial', 'Blocknum', 'Modeflag','Events','Block_Export','Trial_Export','Demodata'};

savelist = setxor(allvars,goldenvariables);

filestosave = [];
for(str = 1: length(savelist))
    filestosave = sprintf('%s''%s'',',filestosave,savelist{str});
end

filestosave = filestosave(1:length(filestosave)-1);

    if IsOSX | IsLinux
        eval_command = sprintf('save(''StreamCore/blockvars'',%s)',filestosave);

    else
        eval_command = sprintf('save(''StreamCore\\blockvars'',%s)',filestosave);
    end


eval(eval_command)



