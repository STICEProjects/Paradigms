%%Initializes psychtoolbox, prompts tester for subject information, and
%%begins running the inputted paradigm(s).


%%paradigm is a cell array of function handles that accept the argument

%%list: Display information Struct, Subject informatio n Struct, and
%%a filepath string. 


function windows_staging_system()
    commandwindow
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

    Display = screen_init('debug');
    
    
    pause(.3);

    Joyconfig = joystick_calibration(Display, 'logitech');
    
    DrawFormattedText(Display.window, 'Press 1 to begin Food exposure. Press 2 to skip Food exposure' ,'center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip',Display.window);
    if get_resp('2@', '1!')
        try
            exposure(Display, Joyconfig, Subject, path, 'Food');
        catch
            sca
            r = input('Food exposure crashed. Enter 1 to continue to the next test or 2 to terminate the program:');
            if r == 2
                return
            end
        end
    end
       
    
    DrawFormattedText(Display.window, 'Press 1 to begin Model exposure. Press 2 to skip Model exposure' ,'center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip',Display.window);
    if get_resp('2@', '1!')
        

            exposure(Display, Joyconfig, Subject, path, 'Model');
        try
        catch
            sca
            r = input('Model exposure has crashed. Enter 1 to continue to the next test or 2 to terminate the program:');
            if r == 1
                Display = screen_init('debug');
            else
                return
            end
        end
    end
    
    
    DrawFormattedText(Display.window, 'Press 1 to begin ED valuation. Press 2 to skip ED valuation' ,'center','center',[255 255 255],50,[],[],1.5);
    Screen('Flip',Display.window);
    if get_resp('2@', '1!')
        try
            eating_disorder_valuation(Display, Joyconfig , Subject, path);
        catch
            sca
            input('ed valuation has crashed. Enter 1 to continue to the next test or 2 to terminate the program:');
        end
    end
    pause(3);
    disp('The program is complete, thank you')
    sca
end

    
                                    
    
    
    
    
   
            
      






