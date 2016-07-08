function [Defaultjoy] = joystick_calibration(type)
   
    Display = screen_init();
    
    if isequal(type, 'logitech') 
    Defaultjoy.center = [32767, 32767];
    Defaultjoy.xmod = .0004;
    Defaultjoy.ymod = .0004;
    Defaultjoy.deadzone = 5000;
    
    Cursor.color = [255 255 255];
    Cursor.position = [960, 540];
    
    Priority(Display.priority);
    else
        if isequal(type, 'mri')
            
        else print('invalid argument'); return;
        end
    end
    
    
    Screen('Flip', Display.window);

    keyisdown = 0;
    while keyisdown == 0
        Screen('DrawDots', Display.window, Cursor.position, 20, Cursor.color, [], 2);
        DrawFormattedText(Display.window,'Control the white dot with the joystick. Please move the dot to each corner of the screen to calibrate','center','center',[150 150 150],50,[],[],1.5);
        Screen('Flip', Display.window);
        
        [keyisdown,~,~] = KbCheck;
        
        Joy = get_joystick_value(Defaultjoy);
        Cursor.position = [Joy.x + Cursor.position(1), Joy.y + Cursor.position(2)];
        Cursor.position(1) = minmaxcheck(0, 1920, Cursor.position(1));
        Cursor.position(2) = minmaxcheck(0, 1080, Cursor.position(2));
        
        %Display.vbl  = Screen('Flip', Display.window, Display.vbl + (Display.waitframes - 0.5) * Display.interval);
        
    end
    
DrawFormattedText(Display.window,'Thank you, the calibration is complete. Please wait','center','center',[255 255 255],50,[],[],1.5);
Screen('Flip', Display.window);
pause(2);
KbWait;
sca
    
    

    