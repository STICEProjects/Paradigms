
%%Initializes psychtoolbox, prompts tester for subject information, and
%%begins running the inputted paradigm(s).


%%paradigm is a cell array of function handles that accept the argument

%%list: Display information Struct, Subject information Struct, and
%%a filepath string. 


function staging_system()


    rng('shuffle'); 
    pause('on');
    prompt={'SUBJECT ID' 'Session' 'MRI (1 = Y, 0 = N)'};
    defAns={'4444' '0' '0'};
    
    textfileNames = {'Binge.txt','Sick.txt','Lax.txt', 'Dietpills.txt', 'Fast.txt', 'Exercise.txt'};
    prompt2={'Binges' 'Sick' 'Laxatives/diruretics' 'Diet pills' 'Fasting' 'Exercise'};
    behaviors={'0' '0' '0' '0' '0' '0'};

    
    answer=inputdlg(prompt,'Please input subject info',1,defAns);
    
    negbehav= inputdlg(prompt2,'Please input behaviors',1,behaviors);
    
      
    Subject.id = str2double(answer{1});
    Subject.session = str2double(answer{2});
    Subject.mri = logical(str2double(answer{3}));
    
    a=logical(str2double(negbehav));

    Subject.eds = {};
    for i = 1:size(a,1)
        if (a(i))
            Subject.eds = [Subject.eds; importdata(textfileNames{i})];
        end
    end


    
    %} 
    
    [path, ~, ~] = fileparts(which('staging_system.m'));
    
    Display = screen_init('debug');
    
    disp('[Press any key to begin running the test]');
    get_resp();
    
    Joyconfig = joystick_calibration(Display, 'logitech');

    disp(Display)
    

    %exposure(Display, Joyconfig, Subject, path, 'Food'); 
    %exposure(Display, Joyconfig, Subject, path, 'Model');
    
    eating_disorder_valuation(Display, Joyconfig , Subject, path);
end
    
                                    
    
    
    
    
    
            
      






