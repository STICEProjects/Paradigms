function exposure(Display, Joyconfig, Subject, path, arg)



Config.blocks = 1;
Config.imagecount = 20;
Config.trials = 2*config.imagecount;
Config.trialdur = 2;
Config.rate_dur = 1;
Config.date = sprintf('%s %2.0f:%02.0f',date,d(4),d(5));
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
data = struct.empty(Config.trials);
jitter = BalanceTrials(Config.blocks*Config.trials,1,Config.jitter);

for i = 1:Config.trials;
    data(i).pictype = order(i,1);

    if order(i,1) == 1
    data(i).picname = Pics.high(order(i,2)).name;
	elseif order(i,1) == 0
        data(i).picname = Pics.low(order(i,2)).name;
    end
         
	data(i).jitter = jitter(i);
	data(i).fix_onset = NaN;
	data(i).pic_onset = NaN;
    data(i).rate_onset = NaN;
    data(i).rate_RT = NaN;
    data(i).rating = 5;
end

commandwindow;

time = mri_sync(Display);

DrawFormattedText(Display.window,'We are going to show you pictures of food. \n\n Press the joystick trigger to continue.','center','center',[255 255 255],50,[],[],1.5);
Screen('Flip', Display.window);
joystick_wait(Joyconfig);


DrawFormattedText(w,'A green border will appear around the image, you will have one second to react with the joystick. \n\n Press the joystick trigger to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
joystick_wait(Joyconfig);

DrawFormattedText(w,'Pull the joystick toward you for foods that you do like. \n\n Push the joystick away from you for foods that you dislike.\n\nPress the joystick trigger to begin.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
joystick_wait(Joyconfig);

for block = 1:STIM.blocks
    for trial = 1:STIM.trials
        tcounter = (block-1)*STIM.trials + trial;
        tpx = imread(getfield(SimpExp,'data',{tcounter},'picname'));
        texture = Screen('MakeTexture',w,tpx);
        
        % Fixation. 20160509cdt
        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        fixon = Screen('Flip',w);
        SimpExp.data(tcounter).fix_onset = fixon - scan_sec;
        WaitSecs(SimpExp.data(tcounter).jitter);
        
        % Intial display of food and instructions. 20160509cdt
        Screen('DrawTexture',w,texture,[],STIM.framerect);
%         DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.WHITE);
        if (usingKeyboard)
            drawRatings([],w);
        end
        picon = Screen('Flip',w);
        SimpExp.data(tcounter).pic_onset = picon - scan_sec;
        WaitSecs(STIM.trialdur - STIM.rate_dur);
        
        % Time to rate the food. 20160509cdt
        Screen('FillRect', w, COLORS.GREEN, STIM.framerect + [-BORDERSIZE -BORDERSIZE BORDERSIZE BORDERSIZE]);
        Screen('DrawTexture',w,texture,[],STIM.framerect);
%         DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.GREEN);
        if (usingKeyboard)
            drawRatings([],w,1); %The 1 here turns everything green.
        end
        rateon = Screen('Flip',w);
        SimpExp.data(tcounter).rate_onset = rateon - scan_sec;
        
        FlushEvents();
        telap = 0;
        while telap < STIM.rate_dur
            telap = GetSecs() - rateon;
            
            if (usingKeyboard)
                [keyisdown, rt, keycode] = KbCheck();
                if (keyisdown==1 && any(keycode(KEYS.all)))
                    SimpExp.data(tcounter).rate_RT = rt - rateon;

                    rating = KbName(find(keycode));
                    rating = str2double(rating(1));

                    Screen('DrawTexture',w,texture,[],STIM.framerect);
                    drawRatings(keycode,w,1);
%                     DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.GREEN);
                    Screen('Flip',w);
                    WaitSecs(.25);
                    if fmri == 1;
                        rating = rating + 1;
                    elseif fmri == 0 && rating == 0
                        rating = 10;
                    end

                    SimpExp.data(tcounter).rating = rating;
                    break;
                end
            else % using joystick 20160509cdt
                n = 0;
                [x, y, z, buttons] = WinJoystickMex(n);
                if (y < joystickCenter - joystickSensitivity)
                    if isnan(SimpExp.data(tcounter).rate_RT)
                        SimpExp.data(tcounter).rate_RT = GetSecs() - rateon;
                    end
                    Screen('FillRect', w, COLORS.GREEN, STIM.framerectfar + [-BORDERSIZE -BORDERSIZE BORDERSIZE BORDERSIZE]);
                    Screen('DrawTexture',w,texture,[],STIM.framerectfar);
%                     DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.GREEN);
                    Screen('Flip',w);
                    SimpExp.data(tcounter).rating = 1;
                    %WaitSecs(.25);
                    fprintf('%d %d %d - %d %d %d %d \n', x, y, z, buttons(1), buttons(2), buttons(3), buttons(4));
                elseif (y > joystickCenter + joystickSensitivity)
                    if isnan(SimpExp.data(tcounter).rate_RT)
                        SimpExp.data(tcounter).rate_RT = GetSecs() - rateon;
                    end
                    Screen('FillRect', w, COLORS.GREEN, STIM.framerectnear + [-BORDERSIZE -BORDERSIZE BORDERSIZE BORDERSIZE]);
                    Screen('DrawTexture',w,texture,[],STIM.framerectnear);
%                     DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.GREEN);
                    Screen('Flip',w);
                    SimpExp.data(tcounter).rating = 9;
                    %WaitSecs(.25);
                    fprintf('%d %d %d - %d %d %d %d \n', x, y, z, buttons(1), buttons(2), buttons(3), buttons(4));
                end

            end
        end        
    end
end %STARTHEREANDDELETETHISTOMORROW










