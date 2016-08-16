
%%Initializes psychtoolbox, prompts tester for subject information, and
%%begins running the inputted paradigm(s).


%%paradigm is a cell array of function handles that accept the argument

%%list: Display information Struct, Subject informatio n Struct, and
%%a filepath string. 


function staging_system()
    addpath('C:\Users\pl7678\Documents\GitHub\STICEprojects\STICElib');
    addpath('C:\Users\pl7678\Documents\GitHub\STICEprojects\Paradigms');
    
    rng('shuffle'); 
    pause('on');
    prompt={'SUBJECT ID' 'Session' 'MRI (1 = Y, 0 = N)'};
    defAns={'4444' '0' '0'};
    
    textfileNames = {'Binge.txt','Sick.txt', 'Lax.txt', 'Dietpills.txt', 'Fast.txt', 'Exercise.txt'};
    prompt2={'Binges' 'Sick' 'Laxatives/diruretics' 'Diet pills' 'Fasting' 'Exercise'};
    behaviors={'0' '0' '0' '0' '0' '0'};

    
    answer=inputdlg(prompt,'Please input subject info',1,defAns);
    
    negbehav= inputdlg(prompt2,'Please input behaviors',1,behaviors);
    [path, ~, ~] = fileparts(which('staging_system.m'));
    
    cd(char([path '/Data/Behavior']));
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
    Subject.eds = Subject.eds(randperm(numel(Subject.eds)));

    
    disp('Press any key to begin running the test');
    get_resp();
    pause(.3);
    
    Display = screen_init();
    Joyconfig = joystick_calibration(Display, 'logitech');
    sca
    disp('Press any key to continue to the next Paradigm')
    get_resp();
    
    Display = screen_init();
    exposure(Display, Joyconfig, Subject, path, 'Food');
    sca
    disp('Press any key to continue to the next Paradigm')
    get_resp(); 
    
    Display = screen_init();
    exposure(Display, Joyconfig, Subject, path, 'Model');
    sca
    disp('Press any key to continue to the next Paradigm')
    get_resp();
    
    Display = screen_init();
    eating_disorder_valuation(Display, Joyconfig , Subject, path);
    sca
    disp('Session complete. Press any key to continue to exit')
    get_resp();
end
    
                                    
    
    
    
    
   
            
      






