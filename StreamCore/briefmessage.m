function briefmessage(Parameters,question,question2,font,fontsize,x,y,time)

%present a message to the user.
%%%%%%%%%Input
% Parameters: Parameterset for this experiment
% question:  line of the user prompt
% question2:  line 2 of the user prompt
% time:  time in seconds to leave the message on the screen.

Screen('TextSize',Parameters.window,fontsize);
Screen('TextFont',Parameters.window,font);

Screen('DrawText',Parameters.window,question, x, y,[0,0,0]);   %draw the prompts
Screen('DrawText',Parameters.window,question2, x, y+fontsize*1.5,[0,0,0]);


Screen('Flip', Parameters.window,0,0);

if(time > 0)
    pause(time);
else
    while(KbCheck(-1))
   'beginning'
    end
    
    while(KbCheck(-1) ==0)
   'ending'
    end
    
end

end



