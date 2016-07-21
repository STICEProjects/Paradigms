function exposure(Display, Joyconfig, Subject, path, arg)



Config.imagecount = 20;
Config.trials = 2*config.imagecount;
Config.trialdur = 2;
Config.rate_dur = 1;
Config.date = sprintf('%s %2.0f:%02.0f',date, d(4), d(5));
if fmri == 1
    Config.jitter = [4 5 6 8];
else Config.jitter = 2;
end

ratepath = string('"%s"/Rating', arg);
picpath = string('"%s"/Pics', arg);

Pics.rating = fullfile(path, ratepath);
Pics.dir = fullfile(path, picpath);

try
    cd(Pics.rating)
catch
    error('Could not find and/or open the folder that contains the image ratings.');
end



Pics.filename = sprintf('PicRate_Food%d.mat', Subject.id);
try
    p = open(Pics.filename);
catch
        warning('Attemped to open file called "%s" for Subject #%d. Could not find and/or open this training rating file. Double check that you have typed in the subject number appropriately.',Pics.filename, Subject.id);
    commandwindow;
    randopics = input('Would you like to continue with a random selection of images? [1 = Yes, 0 = No]');
    if randopics == 1
        cd(Pics.dir)
        p = struct;
        p.PicRating_Food.H = dir('He*');
        p.PicRating_Food.U = dir('Binge*');

    else
        error('Task cannot proceed without images. Contact Erik (elk@uoregon.edu) if you have continued problems.')
    end
    
end

cd(Pics.dir);

Pics.high = struct('name',{p.PicRating_Food.H(1:n_images).name}');
Pics.low = struct('name',{p.PicRating_Food.U(1:n_images).name}');

if isempty(Pics.high) || isempty(Pics.low)
    error('Could not find pics. Please ensure pictures are found in a folder names IMAGES within the folder containing the .m task file.');
end

pictype = [ones(n_images,1); zeros(n_images,1)];
piclist = [randperm(n_images)'; randperm(n_images)'];
trial_types = [pictype piclist];
order = trial_types(randperm(size(trial_types,1)),:);
Trial.data = struct.empty(Config.trials);
jitter = BalanceTrials(Config.blocks*Config.trials,1,Config.jitter);

for i = 1:Config.trials;
    Trial.data(i).pictype = order(i,1);

    if order(i,1) == 1
    Trial.data(i).picname = Pics.high(order(i,2)).name;
	elseif order(i,1) == 0
        data(i).picname = Pics.low(order(i,2)).name;
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

DrawFormattedText(Display.window,'We are going to show you pictures of food. \n\n Press the joystick trigger to continue.','center','center',[255 255 255],50,[],[],1.5);
Screen('Flip', Display.window);
joystick_wait(Joyconfig);

DrawFormattedText(w,'A green border will appear around the image, you will have one second to react with the joystick. \n\n Press the joystick trigger to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
joystick_wait(Joyconfig);

DrawFormattedText(w,'Pull the joystick toward you for foods that you do like. \n\n Push the joystick away from you for foods that you dislike.\n\nPress the joystick trigger to begin.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
joystick_wait(Joyconfig);


for i = 1:Config.trials
    texture = Screen('MakeTexture', Display.window, imread(getfield(Trial,'data',{tcounter},'picname')));
    Time.onset = draw_fixation_cross(Display, SimpExp.data(i).jitter);
    SimpExp.data(i).fix_onset = Time.onset - Time.start;
    
    Screen('FillRect', w, [0 0 255], STIM.framerect + [-100 -100 100 100]);
    Screen('DrawTexture',Display.window,texture,[],STIM.framerect);
    Time.onset = Screen('Flip',w);
    Trial.data(tcounter).pic_onset = Time.onset - Time.start;
    WaitSecs(Config.trialdur - Config.rate_dur);
    
    Screen('FillRect', w, [0 255 0], STIM.framerect + [-100 -100 100 100]);
    Screen('DrawTexture',w,texture,[],STIM.framerect);
    Time.onset = Screen('Flip',w);
    SimpExp.data(i).rate_onset = Time.onset - scan_sec;
        
    FlushEvents();
    Time.response = 0;
    while Time.response < Config.rate_dur
            
        Time.response = GetSecs() - Time.onset;
            
        Input = get_joystick_value(Joyconfig);
        if Input.y > 5*Joyconfig.ymod
            Screen('FillRect', Display.window, [0 255 0], STIM.bigrect + [-BORDERSIZE -BORDERSIZE BORDERSIZE BORDERSIZE]);
            Screen('DrawTexture', Display.window, texture, [], STIM.framerectfar);
            Screen('Flip',w);
            SimpExp.data(i).rating = 9;
            Config.rate_RT = GetSecs - Time.onset;

            Trial.data(i)
            break
        elseif Input.y < 5*Joyconfig.ymod
            Screen('FillRect', Display.window, [0 255 0], STIM.smallrect + [-BORDERSIZE -BORDERSIZE BORDERSIZE BORDERSIZE]);
            Screen('DrawTexture',Display.window, texture, [], STIM.smallrect);
            Screen('Flip',Display.window);
            SimpExp.data(i).rating = 1;
            Config.rate_RT = GetSecs - Time.onset;

            Trial.data(i)
            break

        end
    end        
end



savepath = string('"%s"/"%s"/Results', path, arg);

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


DrawFormattedText(w,'That concludes this task.','center','center',COLORS.WHITE);
Screen('Flip', w);
KbWait();

sca

end











