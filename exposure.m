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

while 1
    Joy = get_joystick_value(Joyconfig);
    if Joy.button1 && Joybutton2
        break
    end
end











