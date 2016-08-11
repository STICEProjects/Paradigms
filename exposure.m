function exposure(Display, Joyconfig, Subject, path, arg)

    d = clock;
    Config.imagecount = 20;
    Config.trials = 2*Config.imagecount;
    Config.trialdur = 2;
    Config.rate_dur = 1;
    Config.date = sprintf('%s %2.0f:%02.0f',date, d(4), d(5));
    if Subject.mri == 1
        Config.jitter = [4 5 6 7 8];
    else Config.jitter = 2;
    end

    ratepath = char(['./Data/' arg '/Ratings']);
    picpath = char(['./Data/' arg '/Pics']);

    Pics.rating = fullfile(path, ratepath);
    Pics.dir = fullfile(path, picpath);

    try
        cd(Pics.rating)
    catch
        error('Could not find and/or open the folder that contains the image ratings.');
    end



    Pics.filename = sprintf('PicRate_%s%d.mat', arg, Subject.id);
    try
        p = open(Pics.filename);
    catch
            warning('Attemped to open file called "%s" for Subject #%d. Could not find and/or open this training rating file. Double check that you have typed in the subject number appropriately.',Pics.filename, Subject.id);
        commandwindow;
        randopics = input('Would you like to continue with a random selection of images? [1 = Yes, 0 = No]');
        if randopics == 1
            cd(Pics.dir)
            p = struct;
            if isequal(arg, 'Food')
                p.PicRating_Food.H = dir('He*');
                p.PicRating_Food.U = dir('Binge*');
            elseif isequal(arg, 'Model')
                p.PicRating_Food.H = dir('Av*');
                p.PicRating_Food.U = dir('Th*');
            end

        else
            error('Task cannot proceed without images. Contact Erik (elk@uoregon.edu) if you have continued problems.')
        end

    end

    cd(Pics.dir);

    Pics.high = struct('name',{p.PicRating_Food.H(1:Config.imagecount).name}');
    Pics.low = struct('name',{p.PicRating_Food.U(1:Config.imagecount).name}');

    if isempty(Pics.high) || isempty(Pics.low)
        error('Could not find pics. Please ensure pictures are found in a folder names IMAGES within the folder containing the .m task file.');
    end

    pictype = [ones(Config.imagecount,1); zeros(Config.imagecount,1)];
    piclist = [randperm(Config.imagecount)'; randperm(Config.imagecount)'];
    trial_types = [pictype piclist];
    order = trial_types(randperm(size(trial_types,1)),:);
    Trial.data = struct.empty(Config.trials, 0);
    jitter = BalanceTrials(Config.trials,1,Config.jitter);

    for i = 1:Config.trials;
        Trial.data(i).pictype = order(i,1);

        if order(i,1) == 1
            Trial.data(i).picname = Pics.high(order(i,2)).name;
        elseif order(i,1) == 0
            Trial.data(i).picname = Pics.low(order(i,2)).name;
        end

        Trial.data(i).jitter = jitter(i);
        Trial.data(i).fix_onset = NaN;
        Trial.data(i).pic_onset = NaN;
        Trial.data(i).rate_onset = NaN;
        Trial.data(i).rate_RT = NaN;
        Trial.data(i).rating = 5;
    end

    commandwindow;



    Time.start = mri_sync(Display);

    text = char(['We are going to show you pictures of ' arg '. \n\n Press both joystick triggers to continue.']);
    DrawFormattedText(Display.window,text,'center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip', Display.window);
    joystick_wait(Joyconfig);
    pause(1);

    DrawFormattedText(Display.window,'A green border will appear around the image, you will have one second to react with the joystick. \n\n Press both joystick triggers to continue.','center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip', Display.window);
    joystick_wait(Joyconfig);
    pause(1);

    if isequal(arg, 'Food')
        DrawFormattedText(Display.window,'Pull the joystick toward you for foods that you do like. \n\n Push the joystick away from you for food that you dislike.\n\nPress both joystick triggers to begin.','center','center',[255 255 255], 50,[],[],1.5);
    elseif isequal(arg, 'Model')
        DrawFormattedText(Display.window,'Pull the joystick toward you for models that you find attractive. \n\n Push the joystick away from you for models that you find unattractive.\n\nPress both joystick triggers to begin.','center','center',[255 255 255], 50,[],[],1.5);
        Screen('Flip', Display.window);
        joystick_wait(Joyconfig);
        pause(1);
    end


    for i = 1:Config.trials
        ptr = imread(getfield(Trial,'data',{i},'picname'));
        texture = Screen('MakeTexture', Display.window, ptr);
        Time.onset = draw_fixation_cross(Display, Trial.data(i).jitter);
        Trial.data(i).fix_onset = Time.onset - Time.start;

        %Screen('FillRect', Display.window, [255 0 0], (Display.imagerect + [-50 -50 50 50]));
        Screen('DrawTexture', Display.window, texture, [], Display.imagerect);
        Time.onset = Screen('Flip',Display.window);
        Trial.data(i).pic_onset = Time.onset - Time.start;
        WaitSecs(Config.trialdur - Config.rate_dur);

        Screen('FillRect', Display.window, [0 255 0], Display.imagerect + [-50 -50 50 50]);
        Screen('DrawTexture',Display.window,texture,[],Display.imagerect);
        Time.onset = Screen('Flip',Display.window);
        Trial.data(i).rate_onset = Time.onset - Time.start;

        Time.response = 0;
        while Time.response < Config.rate_dur

            Time.response = GetSecs() - Time.onset;

            Input = get_joystick_value(Joyconfig);
            if Input.y > 16 * Joyconfig.ymod
                Screen('FillRect', Display.window, [0 255 0], Display.largeimagerect + [-75 -75 75 75]);
                Screen('DrawTexture', Display.window, texture, [], Display.largeimagerect);
                Screen('Flip',Display.window);
                Trial.data(i).rating = 9;
                Trial.data(i).rate_RT = GetSecs - Time.onset;

                Trial.data(i)
                pause(.5);
                break
            elseif Input.y < -8 * Joyconfig.ymod
                Screen('FillRect', Display.window, [0 255 0], Display.smallimagerect + [-25 -25 25 25]);
                Screen('DrawTexture',Display.window, texture, [], Display.smallimagerect);
                Screen('Flip',Display.window);
                Trial.data(i).rating = 1;
                Trial.data(i).rate_RT = GetSecs - Time.onset;

                Trial.data(i)
                pause(.5);
                break

            end
        end        
    end

    Trial.data

    %{

    savepath = char('"%s"/"%s"/Results', path, arg);

    % cd(savedir)
    savename = ['SimpExp_Food_' num2str(ID)];

    if exist(savename,'file')==2;
        savename = ['SimpExp_Food_' num2str(Subject.id) '_' sprintf('%s_%2.0f%02.0f',Config.date,d(4),d(5))];
    end

    mat_savename = [savename '.mat'];
    xls_savename = [savename '.xls'];

    save([savepath mat_savename],'Trial');
    print('saved mat file');

    fields = transpose(fieldnames(Trial.data));
    out_data = transpose(struct2cell(transpose(Trial.data)));
    xlswrite([savedir xls_savename], out_data);
    print('saved xls file');

    %}

    DrawFormattedText(Display.window,'That concludes this task. Please wait','center','center', [255 255 255]);
    Screen('Flip', Display.window);
    get_resp();
end











