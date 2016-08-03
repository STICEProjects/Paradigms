
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
    
    %{
    
    a = str2double(negbehav);
    
    for i = 1:size(a,1)
        if a(i)
            Subject.eval(end+1) = importdata(textfileNames{i});
        end
    end
    
    
    % } 
    
    [path, ~, ~] = fileparts(which('staging_system.m'));
    
    Display = screen_init();
    
    disp('[Press any key to begin running the test]');
    KbName;
   
        
    %pause(2);
    
    
    
    Joyconfig = joystick_calibration(Display, 'mac');
    KbName
    disp(Display)

     exposure(Display, Joyconfig, Subject, path, 'food')
    
                                    
    
    
    
    
    
            
    






