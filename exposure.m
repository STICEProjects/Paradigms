function exposure(Display, Subject, path)

n_images = 20;

Config.blocks = 1;
Config.trials = n_images *2; %n healthy images and n unhealthy images
Config.totes = Config.blocks * Config.trials;
Config.trialdur = 2;
Config.rate_dur = 1;
if fmri == 1
    Config.jitter = [4 5 6 8];
else Config.jitter = 2;
end



Pics.rating = fullfile(path,'Ratings');
Pics.dir = fullfile(path,'Pics');

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

Pics.top = struct('name',{p.PicRating_Food.H(1:n_images).name}');
Pics.bottom = struct('name',{p.PicRating_Food.U(1:n_images).name}');


