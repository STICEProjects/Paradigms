function eating_disorder_valuation(Display, Joyconfig, Subject, path)
    d = clock;
    commandwindow;
    cd(char([path '/Data/Behavior']));

    
    
    Config.stimuluscount = 20;
    
    %Subject.eds = randperm(Subject.eds);
    Config.edcount = length(Subject.eds);
    Stimulus.scenarios = importdata('scenarios.txt');
    Config.scenariocount = length(Stimulus.scenarios);
    Stimulus.neutrals = importdata('neutral_behav.txt');
    Config.neutralcount = length(Stimulus.neutrals);
    
    if Subject.mri == 1
        jitter = [2 3 4 5 6];
    else jitter = 2;
    end
    Config.jitter = BalanceTrials(Config.stimuluscount*3, 1, jitter);
    Config.headers = {'block', 'trial', 'scenario', 'behav1', 'behav1_rate', 'behav1_rt', 'behav2', 'behav2_rate', 'behav2_rt', 'left_choice', 'right_choice', 'versus_rate', 'versus_rt'};
    
    Stimulus.verbage1 = 'How much do you want to...';
    Stimulus.verbage2 = 'Which do you want to do more?';
    Stimulus.index = randperm(size(Stimulus.scenarios, 1), Config.stimuluscount);
    Stimulus.ed_behavior_index = randperm(size(Subject.eds, 1), Config.edcount);
    Stimulus.neutral_behavior_index = randperm(size(Stimulus.scenarios, 1), Config.neutralcount);
    
    
    DrawFormattedText(Display.window,'You are going to imagine yourself in scenarios, then rate how likely you are to engage in a behavior.\n\n You will use a scale from 1 to 9, where 1 is "Not at all likely" and 9 is "Extremely likely."\n\nPress the joystick to continue.','center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip', Display.window);
    joystick_wait(Joyconfig);
    
    DrawFormattedText(Display.window,'You will use joystick and its trigger to select your rating.\n\nPress both joystick triggers to continue.','center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip', Display.window);
    joystick_wait(Joyconfig);
    
    Data.start_time = mri_sync(Display);
    
    DrawFormattedText(Display.window,'The rating task will now begin.\n\nPress both joystick triggers continue.','center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip',Display.window);
    joystick_wait(Joyconfig);
    pause(1);
    
    jitter_index = 1;
    for trial = 1:Config.stimuluscount
        scenario = Stimulus.scenarios{trial};
        ed = Subject.eds{trial};
        neutral = Stimulus.neutrals{trial};
        
         if round(rand(1))
            Data.behavior1 = ed;
            Data.behavior2 = neutral;
        else
            Data.behavior1 = neutral;
            Data.behavior2 = ed;
        end
        
        if round(rand(1))
            Data.choice_left = ed;  
            Data.choice_right = neutral;
        else
            Data.choice_left = neutral;
            Data.choice_right = ed;
        end
        
        [Data.behavior1_rating, Data.behavior1_responsetime] = display_stimulus_rating(Display, Joyconfig, Stimulus.verbage1, Data.behavior1, 5);
        draw_fixation_cross(Display, Config.jitter(jitter_index));
        jitter_index = jitter_index+1;
        pause(.1);
        [Data.behavior2_rating, Data.behavior2_responsetime] = display_stimulus_rating(Display, Joyconfig, Stimulus.verbage1, Data.behavior2, 5);  
        draw_fixation_cross(Display, Config.jitter(jitter_index));
        jitter_index = jitter_index+1;
        pause(.1);
        [Data.choice_rating, Data.choice_responsetime] = display_stimulus_choice(Display, Joyconfig, Stimulus.verbage2, Data.choice_left, Data.choice_right, 5);
        draw_fixation_cross(Display, Config.jitter(jitter_index));
        jitter_index = jitter_index+1;
        
        disp(Data)
    end
        
    DrawFormattedText(Display.window,'That concludes this task. The assessor will be with you soon.','center','center',[255 255 255]);
    Screen('Flip', Display.window);
    

    
