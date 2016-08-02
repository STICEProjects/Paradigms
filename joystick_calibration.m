function [Defaultjoy] = joystick_calibration(Display, type)
    
    if isequal(type, 'logitech') 
        Defaultjoy.center = [32767, 32767];
        Defaultjoy.xmod = .0004;
        Defaultjoy.ymod = .0004;
        Defaultjoy.deadzone = 5000;
    elseif isequal(type, 'mri')
        Defaultjoy.center = [33153, 33346]; %MINY = ~13000 MAXY= 41000 MINX = 19000 MAXX = 52000 ADJUST THE CENTER!
        Defaultjoy.xmod = .0008;
        Defaultjoy.ymod = .0008;
        Defaultjoy.deadzone = 1000;
        else print('invalid argument'); return;
    end
    
    Cursor.color = [255 255 255];
    Cursor.position = [960, 540];
    
    Priority(Display.priority);
    
    Screen('Flip', Display.window);

    flag = [0 0 0 0]
    keyisdown = 0;
    while keyisdown == 0
        Screen('DrawDots', Display.window, Cursor.position, 20, Cursor.color, [], 2);
        DrawFormattedText(Display.window,'Control the white dot with the joystick. Please move the dot to each edge of the screen to calibrate','center','center',[150 150 150],50,[],[],1.5);
        Screen('Flip', Display.window);
        
        [keyisdown,~,~] = KbCheck;
        
        Joy = get_joystick_value(Defaultjoy);
        Cursor.position = [Joy.x + Cursor.position(1), Joy.y + Cursor.position(2)];
        Cursor.position(1) = minmaxcheck(10, 1900, Cursor.position(1));
        Cursor.position(2) = minmaxcheck(10, 1060, Cursor.position(2));
        
        if Cursor.position(1)<100
            flag(1) = 1;
        end
        if Cursor.position(1)>1800
            flag(2) = 1;
        end
        if Cursor.position(2)<100
            flag(3) = 1;
        end
        if Cursor.position(2)>960
            flag(4) = 1;
        end
        
        if isequal(flag, [1 1 1 1]) || keyisdown
            break
        end
        
       
        
    end
    
    
    
DrawFormattedText(Display.window,'Thank you, the calibration is complete. Please wait','center','center',[255 255 255],50,[],[],1.5);
Screen('Flip', Display.window);
pause(2);
KbWait;
    
    

    