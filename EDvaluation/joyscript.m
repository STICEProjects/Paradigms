FlushEvents();
while 1
    [x, y, z, buttons] = WinJoystickMex(0);
    if sum(buttons) > 0
        break;
    end
    WaitSecs(0.10);
end

disp(buttons);