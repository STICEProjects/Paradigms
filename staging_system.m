function staging_system()

    Display = screen_init();

    rng('shuffle');
    
    prompt={'SUBJECT ID' 'Session' 'MRI (1 = Y, 0 = N)'};
    defAns={'4444' '0' '0'};

    textfileNames = {'Binge.txt','Sick.txt','Lax.txt', 'Dietpills.txt', 'Fast.txt', 'Exercise.txt'};
    prompt2={'Binges' 'Sick' 'Laxatives/diruretics' 'Diet pills' 'Fasting' 'Exercise'};
    behaviors={'0' '0' '0' '0' '0' '0'};


    answer=inputdlg(prompt,'Please input subject info',1,defAns);

    negbehav= inputdlg(prompt2,'Please input behaviors',1,behaviors);
    
    Subject.id = str2int(answer{1});
    Subject.session = str2int(answer{2});
    Subject.mri = logical(str2int(answer{3}));
    
    a = str2int(negbehav);
    for i = 1:size(a,1)
        if a(i)
            Subject.eval(end+1) = importdata(textfileNames{i});
        end
    end
    
    [maindir, ~, ~] = fileparts(which('staging_system.m'));
    
    paradigm = input('Please enter the Paradigm you would like to run or the name of a premade set (ex: body_project or body_project_mri');
    
    paradigm(Subject, Display, maindir)
    
    
    
    
            
    






