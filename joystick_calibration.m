function [Defaultjoy] = joystick_calibration(Display, type)
    
    if isequal(type, 'logitech') 
        Defaultjoy.mac = 0
        Defaultjoy.center = [32767, 32767];
        Defaultjoy.xmod = .0004;
        Defaultjoy.ymod = .0004;
        Defaultjoy.deadzone = 5000;
    elseif isequal(type, 'mri') 
        Gamepad();
        DrawFormattedText(Display.window,'Calibrating Joystick center, please do not touch or move the joystick','center','center',[255 255 255],50,[],[],1.5);
        Screen('Flip', Display.window);
        pause(3);
        Defaultjoy.center = [Gamepad('Getaxis', 1, 1) Gamepad('Getaxis', 1, 2)];
        disp(Defaultjoy.center)
        disp('press y to accept this center, n to discard(will exit program)')
        if get_resp('y', 'n')
            disp('joystick calibration discarded, please restart the program');
            return
        end
        
        Defaultjoy.mac = 1;
        Defaultjoy.xmod = .0005;
        Defaultjoy.ymod = .0005;
        Defaultjoy.deadzone = 3000;
        else print('invalid argument'); return;
            
    end
    %{
    Cursor.color = [255 255 255];
    Cursor.position = [960, 540];
    
    Priority(Display.priority);
    
    Screen('Flip', Display.window);

    flag = [0 0 0 0];
    keyisdown = 0;
    time = GetSecs();
    while 2 > GetSecs() - time;
        Screen('DrawDots', Display.window, Cursor.position, 20, Cursor.color, [], 2);
        DrawFormattedText(Display.window,'Control the white dot with the joystick. Please move the dot to each edge of the screen','center','center',[150 150 150],50,[],[],1.5);
        Screen('Flip', Display.window);
        
        
        
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
        
        if  isequal(flag, [1 1 1 1])
            break
        end
    end
    
    DrawFormattedText(Display.window,'When the green dot appears, press both joystick buttons at the same time \n\n (the second button is on the top of the joystick)','center','center',[150 150 150],50,[],[],1.5);
    for i = 1:3
        DrawFormattedText(Display.window,'When the green dot appears, press both joystick buttons at the same time \n\n (the second button is on the top of the joystick)','center','center',[150 150 150],50,[],[],1.5);
        Screen('Flip', Display.window);
        disp('press any key to continue');
        get_resp();
        
        Cursor.color = [0 255 0];
        DrawFormattedText(Display.window,'When the green dot appears, press both joystick buttons at the same time \n\n (the second button is on the top of the joystick)','center','center',[150 150 150],50,[],[],1.5);
        Screen('DrawDots', Display.window, Display.center, 20, Cursor.color, [], 2);
        Screen('Flip', Display.window);
        joystick_wait(Defaultjoy);
        
        Cursor.color = [255 0 0];
        DrawFormattedText(Display.window,'When the green dot appears, press both joystick buttons at the same time \n\n (the second button is on the top of the joystick)','center','center',[150 150 150],50,[],[],1.5);
        Screen('DrawDots', Display.window, Display.center, 20, Cursor.color, [], 2);
        Screen('Flip', Display.window);
    end
%}
DrawFormattedText(Display.window,'Thank you, the calibration is complete. Please wait','center','center',[255 255 255],50,[],[],1.5);
Screen('Flip', Display.window);
pause(5);
    
    

    