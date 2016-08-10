function ED_valuation()
    % Rate all images, choose top X picsn
    % fMRI commented out.
    

    global wRect w XCENTER rects mids COLORS KEYS joystickCenter telap rateon MRI

    Defaultjoy.center = [672 31];
    Defaultjoy.xmod = .00003;
    Defaultjoy.ymod = .00003;
    Defaultjoy.deadzone = 2000;
    Defaultjoy.mac = 1;
    
    prompt={'SUBJECT ID' 'Session' 'MRI (1 = Y, 0 = N)'};
    defAns={'4444' '0' '0'};

    textfileNames = {'Binge.txt','Sick.txt','Lax.txt', 'Dietpills.txt', 'Fast.txt', 'Exercise.txt'};
    prompt2={'Binges' 'Sick' 'Laxatives/diruretics' 'Diet pills' 'Fasting' 'Exercise'};
    behaviors={'0' '0' '0' '0' '0' '0'};


    answer=inputdlg(prompt,'Please input subject info',1,defAns);

    negbehav= inputdlg(prompt2,'Please input behaviors',1,behaviors);

    ID=str2double(answer{1});
    SESS=str2double(answer{2});
    MRI = str2double(answer{3});
    
    a=logical(str2double(negbehav));

    eds = {};
    for i = 1:size(a,1)
        if (a(i))
            eds = [eds; importdata(textfileNames{i})];
        end
    end
% 
%     eds
%     prompt2(a);

    COLORS = struct;
    COLORS.BLACK = [0 0 0];
    COLORS.WHITE = [255 255 255];
    COLORS.RED = [255 0 0];
    COLORS.BLUE = [0 0 255];
    COLORS.GREEN = [0 255 0];
    COLORS.YELLOW = [255 255 0];
    COLORS.rect = COLORS.GREEN;

    KbName('UnifyKeyNames');

    KEYS = struct;
    % KEYS.LEFT=KbName('leftarrow');
    % KEYS.RIGHT=KbName('rightarrow');
    %KEYS.ZERO= KbName('0!');
    KEYS.ONE= KbName('1!');
    KEYS.TWO= KbName('2@');
    KEYS.THREE= KbName('3#');
    KEYS.FOUR= KbName('4$');
    KEYS.FIVE= KbName('5%');
    KEYS.SIX= KbName('6^');
    KEYS.SEVEN= KbName('7&');
    KEYS.EIGHT= KbName('8*');
    KEYS.NINE= KbName('9(');
    %KEYS.TEN= KbName('10)');
    rangetest = cell2mat(struct2cell(KEYS));
    KEYS.all = min(rangetest):max(rangetest);
    % KEYS.trigger = KbName('''"');
    %KEYS.trigger = KbName('''');

    %%
    [mfilesdir,~,~] = fileparts(which('ED_valuation.m'));
    outputdir = [mfilesdir '\Results'];

    %Load in sentence strings
    scenarios = importdata('scenarios.txt');
    neutrals = importdata('neutral_behav.txt');

    num_blocks = 1;
    n_stim = 20;
    jittered_fixations_per_trial = 3;
    n_ed = length(eds);
    n_neutral = length(neutrals);
    if MRI == 1
        jitter_range = [2 3 4 5 6];
    else jitter_range = 2;
    end
    jitters = BalanceTrials(num_blocks * n_stim * jittered_fixations_per_trial, 1, jitter_range);
   
    % 20160611cdt
    usingKeyboard = false;


    %%
    commandwindow;

    %%
    %change this to 0 to fill whole screen
    DEBUG=0;
    clear Screen;
    %set up the screen and dimensions

    %list all the screens, then just pick the last one in the list (if you have
    %only 1 monitor, then it just chooses that one)
    Screen('Preference', 'SkipSyncTests', 1);

    screenNumber=max(Screen('Screens'));

    if DEBUG==1
        %create a rect for the screen
        PsychDebugWindowConfiguration(0,.3)
        %change screen resolution
    %     Screen('Resolution',0,1024,768,[],32);
    end
        %this gives the x and y dimensions of our screen, in pixels.
        [swidth, sheight] = Screen('WindowSize', screenNumber);
        XCENTER=fix(swidth/2);
        YCENTER=fix(sheight/2);
        %when you leave winRect blank, it just fills the whole screen
        winRect=[];


    %open a window on that monitor. 32 refers to 32 bit color depth (millions of
    %colors), winRect will either be a 1024x768 box, or the whole screen. The
    %function returns a window "w", and a rect that represents the whole
    %screen. 
    [w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

    %%
    %you can set the font sizes and styles here
    Screen('TextFont', w, 'Arial');
    %Screen('TextStyle', w, 1);
    Screen('TextSize',w,65);

    %% Dat Grid
    [rects,mids] = DrawRectsGrid();
    verbage = 'How much do you want to...';
    verbage2 = 'Which do you want to do more?';

    %% Intro

    DrawFormattedText(w,'You are going to imagine yourself in scenarios, then rate how likely you are to engage in a behavior.\n\n You will use a scale from 1 to 9, where 1 is "Not at all likely" and 9 is "Extremely likely."\n\nPress the joystick to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
    Screen('Flip',w);
    %KbWait([],3);
    joystick_wait(Defaultjoy);

    FlushEvents();
    
    DrawFormattedText(w,'You will use joystick and its trigger to select your rating.\n\nPress the joystick trigger to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
    Screen('Flip',w);
    %KbWait([],3);
    joystick_wait(Defaultjoy);

    FlushEvents();
    
    %% fMRI synch w/trigger
%    if MRI == 1
%         DrawFormattedText(w,'Synching with fMRI: Waiting for trigger','center','center',COLORS.WHITE);
%         Screen('Flip',w);
%         while 1
%             [keyIsDown, keyTime, keyCodes, deltaTime] = KbCheck();
% 
%             % Check that pressed keycodes and the desired codes overlap
%             % If so, then exit loop
%             if keyIsDown
%                 if keyCodes(KEYS.trigger)
%                     break;
%                 end
%             end
%         end
    
%    else
%      scan_sec = GetSecs();
%    end

    %%
    DrawFormattedText(w,'The rating task will now begin.\n\nPress the joystick trigger continue.','center','center',COLORS.WHITE,50,[],[],1.5);
    Screen('Flip',w);
    %KbWait([],3);
    joystick_wait(Defaultjoy);
    WaitSecs(1);

    jitter_idx = 0; 
    data = {'block', 'trial', 'scenario', 'behav1', 'behav1_rate', 'behav1_rt', 'behav2', 'behav2_rate', 'behav2_rt', 'left_choice', 'right_choice', 'versus_rate', 'versus_rt'};
    
    for block = 1:num_blocks
        stim_index = randperm(size(scenarios, 1), n_stim);
        ed_index = randperm(size(eds, 1), n_ed);
        neutral_index = randperm(size(scenarios, 1), n_neutral);

        %These are catches to make sure that there are at least as many behaviors
        %as there are scenarios. 
        while length(ed_index)<length(stim_index)
            ed_index = [ed_index, randperm(n_ed)];
        end

        while length(neutral_index)<length(stim_index)
            neutral_index = [neutral_index, randperm(n_neutral)];
        end

        for trial = 1:n_stim
            
            % Intialize per-trial variables.
            scenario = scenarios{stim_index(trial)};
            ed = eds{ed_index(trial)};
            neutral = neutrals{neutral_index(trial)};
            
            %joined = strcat(ed,{'                                '},neutral);
            %join = joined{1};   %Embarrassing. But functional. 
           
            if rand(1)>0.5
                choices = struct;
                choices.left = ed;
                choices.right = neutral;
            else
                choices = struct;
                choices.left = neutral;
                choices.right = ed;
            end 
          

            % 20160611cdt
            rating_duration = 5; % seconds

            %Display scenario
            DrawFormattedText(w,scenario,'center','center',COLORS.WHITE,50,[],[],1.5);
            Screen('Flip',w);
            WaitSecs(2);
            
            %TRACKS ED OR NEUTRAL FIRST
            if rand(1)>0.5
                s_order = 1;
                %Probe ED behavior
                [ed_rating, ed_rt] = ShowStim(w, verbage, ed, rating_duration);
                jitter_idx = jitter_idx + 1;
                ShowFixation(w, jitters(jitter_idx));
                %Probe neutral behavior
                [n_rating, n_rt] = ShowStim(w, verbage, neutral, rating_duration);
                jitter_idx = jitter_idx + 1;
                ShowFixation(w, jitters(jitter_idx));       
            else
                s_order = 1;
                %Probe neutral behavior
                [n_rating, n_rt] = ShowStim(w, verbage, neutral, rating_duration);
                jitter_idx = jitter_idx + 1;
                ShowFixation(w, jitters(jitter_idx));
            
                %Probe ED behavior
                [ed_rating, ed_rt] = ShowStim(w, verbage, ed, rating_duration);
                jitter_idx = jitter_idx + 1;
                ShowFixation(w, jitters(jitter_idx));
            end
            
            
            %ED vs neutral beahvior valuation
            [v_rating, v_rt] = ShowStimChoice(w, verbage2, choices, rating_duration);
            jitter_idx = jitter_idx + 1;
            ShowFixation(w, jitters(jitter_idx));

            if s_order == 0
                entry = {block, trial, scenario, ed, ed_rating, ed_rt, neutral, n_rating, n_rt, choices.left, choices.right, v_rating, v_rt};
            elseif s_order == 1
                entry = {block, trial, neutral, n_rating, n_rt, scenario, ed, ed_rating, ed_rt, choices.left, choices.right, v_rating, v_rt};
            end
            data = [data; entry];
        end
        %     %Take a break every 20 pics.
        Screen('Flip',w);
        DrawFormattedText(w,'Press the joystick trigger when you are ready to continue','center','center',COLORS.WHITE);
        Screen('Flip',w);
        %KbWait([],3);
        joystick_wait(Defaultjoy);
    end   
    
    filename = ['ED_valuation' '_sub' answer{1} '_sess' answer{2} '.mat'];
    xls_savename = ['ED_valuation' '_sub' answer{1} '_sess' answer{2} '.xls'];
    cd(outputdir);
    save(filename, 'data');
    xlswrite(xls_savename, data);

    Screen('Flip',w);
        %% Sort & Save List of Foods.

    DrawFormattedText(w,'That concludes this task. The assessor will be with you soon.','center','center',COLORS.WHITE);
    Screen('Flip', w);
    WaitSecs(5);

    sca

end


%%    
function [rating, rt] = ShowStimChoice(w, text1, text2, duration)

    global XCENTER KEYS COLORS wRect usingKeyboard telap rateon

    Defaultjoy.center = [32767, 32767];
    Defaultjoy.xmod = .00003;
    Defaultjoy.ymod = .00003;
    Defaultjoy.deadzone = 2000;
    Defaultjoy.mac = 1;
    
    
    DrawFormattedText(w,text1,'center','center',COLORS.WHITE);
    DrawFormattedText(w,text2.left,wRect(3)*0.10,(wRect(4)*.75),COLORS.WHITE);
    DrawFormattedText(w,text2.right,wRect(3)*0.60,(wRect(4)*.75),COLORS.WHITE);
    rateon = Screen('Flip',w);
    
    FlushEvents();
    telap = 0;
    rating = 5;
    rt = 0;

    while telap < duration
        telap = GetSecs() - rateon;

        if (usingKeyboard)
            % Keyboard funcationality left undone. 20160513cdt
            [keyisdown, rt, keycode] = KbCheck();
            if (keyisdown==1 && any(keycode(KEYS.all)))
                rating = KbName(find(keycode));
                rating = str2double(rating(1));
                DrawFormattedText(w,text1,'center','center',COLORS.WHITE);
                DrawFormattedText(w,text2.left,wRect(3)*0.20,(wRect(4)*.75),COLORS.WHITE);
                DrawFormattedText(w,text2.right,wRect(3)*0.80,(wRect(4)*.75),COLORS.WHITE);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        else
            DrawFormattedText(w,text1,'center','center',COLORS.WHITE);
            if rt > 0
                Screen('Flip',w);
                WaitSecs(0.10);
                break;
            end
            keycode = zeros();
            [rating, rt] = GetJoystickValue(rating);
            
            left_color = COLORS.WHITE;
            right_color = COLORS.WHITE;
            if rating < 4
                left_color = COLORS.GREEN;
            end
            if rating > 6
                right_color = COLORS.GREEN;
            end
            DrawFormattedText(w,text2.left,wRect(3)*0.10,(wRect(4)*.75),left_color);
            DrawFormattedText(w,text2.right,wRect(3)*0.60,(wRect(4)*.75),right_color);
            Screen('Flip',w);
            WaitSecs(0.10);
        end
    end
end

 
%%
 function [rating, rt] = ShowStim(w, text1, text2, duration)
    global KEYS COLORS wRect usingKeyboard telap rateon
    
    drawRatings([],w);
    DrawFormattedText(w,text1,'center','center',COLORS.WHITE);
    DrawFormattedText(w,text2,'center',(wRect(4)*.75),COLORS.WHITE);
    rateon = Screen('Flip',w);
    
    FlushEvents();
    telap = 0;
    rating = 5;
    rt = 0;

    while telap < duration
        telap = GetSecs() - rateon;

        if (usingKeyboard)
            [keyisdown, rt, keycode] = KbCheck();
            if (keyisdown==1 && any(keycode(KEYS.all)))
                rating = KbName(find(keycode));
                rating = str2double(rating(1));
                drawRatings(keycode,w);
                DrawFormattedText(w,text1,'center','center',COLORS.WHITE);
                DrawFormattedText(w,text2,'center',(wRect(4)*.75),COLORS.WHITE);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        else
            if rt > 0
                drawRatings(keycode, w, rating);
            else
                keycode = zeros();
                [rating, rt] = GetJoystickValue(rating);
                keycode(round(rating) + 48) = true;
                drawRatings(keycode);
            end
            DrawFormattedText(w,text1,'center','center',COLORS.WHITE);
            DrawFormattedText(w,text2,'center',(wRect(4)*.75),COLORS.WHITE);
            Screen('Flip',w);
            WaitSecs(0.10);
        end
    end
end


%%


%% broken as of 20160513cdt
function key_time = MyKbWait(varargin)
    global KEYS;
    test_key = KEYS.all;
    if nargin > 0
        test_key = varargin{1};
    end
    FlushEvents();
    while 1
        [pracDown, key_time, pracCode] = KbCheck();
        if pracDown == 1 && any(pracCode(test_key))
            break
        end
    end
end


%%
function ShowFixation(w,duration)
    global COLORS;
    DrawFormattedText(w,'+','center','center',COLORS.WHITE);
    Screen('Flip',w);
    WaitSecs(duration);
end


%% Gets value in range [1..9] based on joystick position
%  in left-right direction.
% Assumes that min and max values returned by the joystick driver
%  are of the same sign.
%  Returns: val - value of selection 1..9.
%           rt - reaction time.
function [rating, rt] = GetJoystickValue(rating)

        global telap rateon MRI ;
    rt = 0;
    Defaultjoy.center = [672 31];
    Defaultjoy.xmod = .00001;
    Defaultjoy.ymod = .00001;
    Defaultjoy.deadzone = 2000;
    Defaultjoy.mac = 1;
    

    if MRI == 1
        effectiveMinValue = 20000;
        effectiveMaxValue = 50000;
    else
        effectiveMinValue = 0;
        effectiveMaxValue = 65536;
    end

    Input = get_joystick_value(Defaultjoy);
    
    
    rating = rating+Input.x;
    rating = max(1, rating);
    rating = min(9, rating);

    if Input.button1 && Input.button2
        rt = GetSecs() - rateon;
    end
end


%%
function [ rects,mids ] = DrawRectsGrid(varargin)
%DrawRectGrid:  Builds a grid of squares with gaps in between.

global wRect XCENTER

%Size of image will depend on screen size. First, an area approximately 80%
%of screen is determined. Then, images are 1/4th the side of that square
%(minus the 3 x the gap between images.

num_rects = 9;                 %How many rects?
xlen = wRect(3)*.8;           %Make area covering about 90% of vertical dimension of screen.
gap = 10;                       %Gap size between each rect
square_side = fix((xlen - (num_rects-1)*gap)/num_rects); %Size of rect depends on size of screen.

squart_x = XCENTER-(xlen/2);
squart_y = wRect(4)*.8;         %Rects start @~80% down screen.

rects = zeros(4,num_rects);

% for row = 1:DIMS.grid_row;
    for col = 1:num_rects;
%         currr = ((row-1)*DIMS.grid_col)+col;
        rects(1,col)= squart_x + (col-1)*(square_side+gap);
        rects(2,col)= squart_y;
        rects(3,col)= squart_x + (col-1)*(square_side+gap)+square_side;
        rects(4,col)= squart_y + square_side;
    end
% end
mids = [rects(1,:)+square_side/2; rects(2,:)+square_side/2+5];

end


%%
function drawRatings(varargin)

    global w KEYS COLORS rects mids;

    colors=repmat(COLORS.WHITE',1,9);
    % rects=horzcat(allRects.rate1rect',allRects.rate2rect',allRects.rate3rect',allRects.rate4rect');

    %Needs to feed in "code" from KbCheck, to show which key was chosen.
    choice = 0;
    if nargin >= 1 && ~isempty(varargin{1})
        response=varargin{1};

        key=find(response);
        if length(key)>1
            key=key(1);
        end;
        choice = 5;
        switch key

            case {KEYS.ONE}
                choice=1;
            case {KEYS.TWO}
                choice=2;
            case {KEYS.THREE}
                choice=3;
            case {KEYS.FOUR}
                choice=4;
            case {KEYS.FIVE}
                choice=5;
            case {KEYS.SIX}
                choice=6;
            case {KEYS.SEVEN}
                choice=7;
            case {KEYS.EIGHT}
                choice=8;
            case {KEYS.NINE}
                choice=9;
        end

        if exist('choice','var')
            colors(choice)=COLORS.GREEN';
        end
    end

    if nargin>=2 && ~isempty(varargin{2})
        window=varargin{2};
    else
       window=w;
    end
    
    choice_selected = -1;
    if nargin >= 3 && ~isempty(varargin{3})
        choice_selected = floor(varargin{3});
    end

    Screen('TextFont', window, 'Arial');
    oldStyle = Screen('TextStyle', window, 1);
    oldSize = Screen('TextSize',window,65);

    %draw all the squares
    Screen('FrameRect',window,colors,rects,1);

    %draw the text (1-10)
    % 20160512cdt add green color to selected number
    for n = 1:9;
        numnum = sprintf('%d',n);
        color = COLORS.WHITE;
        localOldSize = Screen('TextSize', window);
        if choice_selected == n
            localOldSize = Screen('TextSize', window, 35 + 10);
            color = COLORS.GREEN;
        else
            if n == choice
                color = COLORS.GREEN;
            end
        end
        CenterTextOnPoint(window,numnum,mids(1,n),mids(2,n),color);
        Screen('TextSize', window, localOldSize);
    end

    Screen('TextSize',window,oldSize);

end


%%
function [nx, ny, textbounds] = CenterTextOnPoint(win, tstring, sx, sy,color)
% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft])
%
% 

numlines=1;

if nargin < 1 || isempty(win)
    error('CenterTextOnPoint: Windowhandle missing!');
end

if nargin < 2 || isempty(tstring)
    % Empty text string -> Nothing to do.
    return;
end

% Store data class of input string for later use in re-cast ops:
stringclass = class(tstring);

% Default x start position is left border of window:
if isempty(sx)
    sx=0;
end

% if ischar(sx) && strcmpi(sx, 'center')
%     xcenter=1;
%     sx=0;
% else
%     xcenter=0;
% end

xcenter=0;

% No text wrapping by default:
% if nargin < 6 || isempty(wrapat)
    wrapat = 0;
% end

% No horizontal mirroring by default:
% if nargin < 7 || isempty(flipHorizontal)
    flipHorizontal = 0;
% end

% No vertical mirroring by default:
% if nargin < 8 || isempty(flipVertical)
    flipVertical = 0;
% end

% No vertical mirroring by default:
% if nargin < 9 || isempty(vSpacing)
    vSpacing = 1.5;
% end

% if nargin < 10 || isempty(righttoleft)
    righttoleft = 0;
% end

% Convert all conventional linefeeds into C-style newlines:
newlinepos = strfind(char(tstring), '\n');

% If '\n' is already encoded as a char(10) as in Octave, then
% there's no need for replacemet.
if char(10) == '\n' %#ok<STCMP>
   newlinepos = [];
end

% Need different encoding for repchar that matches class of input tstring:
if isa(tstring, 'double')
    repchar = 10;
elseif isa(tstring, 'uint8')
    repchar = uint8(10);    
else
    repchar = char(10);
end

while ~isempty(newlinepos)
    % Replace first occurence of '\n' by ASCII or double code 10 aka 'repchar':
    tstring = [ tstring(1:min(newlinepos)-1) repchar tstring(min(newlinepos)+2:end)];
    % Search next occurence of linefeed (if any) in new expanded string:
    newlinepos = strfind(char(tstring), '\n');
end

% % Text wrapping requested?
% if wrapat > 0
%     % Call WrapString to create a broken up version of the input string
%     % that is wrapped around column 'wrapat'
%     tstring = WrapString(tstring, wrapat);
% end

% Query textsize for implementation of linefeeds:
theight = Screen('TextSize', win) * vSpacing;

% Default y start position is top of window:
if isempty(sy)
    sy=0;
end

winRect = Screen('Rect', win);
winHeight = RectHeight(winRect);

% if ischar(sy) && strcmpi(sy, 'center')
    % Compute vertical centering:
    
    % Compute height of text box:
%     numlines = length(strfind(char(tstring), char(10))) + 1;
    %bbox = SetRect(0,0,1,numlines * theight);
    bbox = SetRect(0,0,1,theight);
    
    
    textRect=CenterRectOnPoint(bbox,sx,sy);
    % Center box in window:
    [rect,dh,dv] = CenterRect(bbox, textRect);

    % Initialize vertical start position sy with vertical offset of
    % centered text box:
    sy = dv;
% end

% Keep current text color if noone provided:
if nargin < 5 || isempty(color)
    color = [];
end

% Init cursor position:
xp = sx;
yp = sy;

minx = inf;
miny = inf;
maxx = 0;
maxy = 0;


[previouswin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

% OpenGL rendering for this window active?
if IsOpenGLRendering
    % Yes. We need to disable OpenGL mode for that other window and
    % switch to our window:
    Screen('EndOpenGL', win);
end

% Disable culling/clipping if bounding box is requested as 3rd return
% % argument, or if forcefully disabled. Unless clipping is forcefully
% % enabled.
% disableClip = (ptb_drawformattedtext_disableClipping ~= -1) && ...
%               ((ptb_drawformattedtext_disableClipping > 0) || (nargout >= 3));
% 

disableClip=1;

% Parse string, break it into substrings at line-feeds:
while ~isempty(tstring)
    % Find next substring to process:
    crpositions = strfind(char(tstring), char(10));
    if ~isempty(crpositions)
        curstring = tstring(1:min(crpositions)-1);
        tstring = tstring(min(crpositions)+1:end);
        dolinefeed = 1;
    else
        curstring = tstring;
        tstring =[];
        dolinefeed = 0;
    end

    if IsOSX
        % On OS/X, we enforce a line-break if the unwrapped/unbroken text
        % would exceed 250 characters. The ATSU text renderer of OS/X can't
        % handle more than 250 characters.
        if size(curstring, 2) > 250
            tstring = [curstring(251:end) tstring]; %#ok<AGROW>
            curstring = curstring(1:250);
            dolinefeed = 1;
        end
    end
    
    if IsWin
        % On Windows, a single ampersand & is translated into a control
        % character to enable underlined text. To avoid this and actually
        % draw & symbols in text as & symbols in text, we need to store
        % them as two && symbols. -> Replace all single & by &&.
        if isa(curstring, 'char')
            % Only works with char-acters, not doubles, so we can't do this
            % when string is represented as double-encoded Unicode:
            curstring = strrep(curstring, '&', '&&');
        end
    end
    
    % tstring contains the remainder of the input string to process in next
    % iteration, curstring is the string we need to draw now.

    % Perform crude clipping against upper and lower window borders for
    % this text snippet. If it is clearly outside the window and would get
    % clipped away by the renderer anyway, we can safe ourselves the
    % trouble of processing it:
    if disableClip || ((yp + theight >= 0) && (yp - theight <= winHeight))
        % Inside crude clipping area. Need to draw.
        noclip = 1;
    else
        % Skip this text line draw call, as it would be clipped away
        % anyway.
        noclip = 0;
        dolinefeed = 1;
    end
    
    % Any string to draw?
    if ~isempty(curstring) && noclip
        % Cast curstring back to the class of the original input string, to
        % make sure special unicode encoding (e.g., double()'s) does not
        % get lost for actual drawing:
        curstring = cast(curstring, stringclass);
        
        % Need bounding box?
%         if xcenter || flipHorizontal || flipVertical
            % Compute text bounding box for this substring:
            bbox=Screen('TextBounds', win, curstring, [], [], [], righttoleft);
%         end
        
        % Horizontally centered output required?
%         if xcenter
            % Yes. Compute dh, dv position offsets to center it in the center of window.
%             [rect,dh] = CenterRect(bbox, winRect);
            [rect,dh] = CenterRect(bbox, textRect);
            % Set drawing cursor to horizontal x offset:
            xp = dh;
%         end
            
%         if flipHorizontal || flipVertical
%             textbox = OffsetRect(bbox, xp, yp);
%             [xc, yc] = RectCenter(textbox);
% 
%             % Make a backup copy of the current transformation matrix for later
%             % use/restoration of default state:
%             Screen('glPushMatrix', win);
% 
%             % Translate origin into the geometric center of text:
%             Screen('glTranslate', win, xc, yc, 0);
% 
%             % Apple a scaling transform which flips the direction of x-Axis,
%             % thereby mirroring the drawn text horizontally:
%             if flipVertical
%                 Screen('glScale', win, 1, -1, 1);
%             end
%             
%             if flipHorizontal
%                 Screen('glScale', win, -1, 1, 1);
%             end
% 
%             % We need to undo the translations...
%             Screen('glTranslate', win, -xc, -yc, 0);
%             [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
%             Screen('glPopMatrix', win);
%         else
            [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
%         end
    else
        % This is an empty substring (pure linefeed). Just update cursor
        % position:
        nx = xp;
        ny = yp;
    end

    % Update bounding box:
    minx = min([minx , xp, nx]);
    maxx = max([maxx , xp, nx]);
    miny = min([miny , yp, ny]);
    maxy = max([maxy , yp, ny]);

    % Linefeed to do?
    if dolinefeed
        % Update text drawing cursor to perform carriage return:
        if xcenter==0
            xp = sx;
        end
        yp = ny + theight;
    else
        % Keep drawing cursor where it is supposed to be:
        xp = nx;
        yp = ny;
    end
    % Done with substring, parse next substring.
end

% Add one line height:
maxy = maxy + theight;

% Create final bounding box:
textbounds = SetRect(minx, miny, maxx, maxy);

% Create new cursor position. The cursor is positioned to allow
% to continue to print text directly after the drawn text.
% Basically behaves like printf or fprintf formatting.
nx = xp;
ny = yp;

% Our work is done. If a different window than our target window was
% active, we'll switch back to that window and its state:
if previouswin > 0
    if previouswin ~= win
        % Different window was active before our invocation:

        % Was that window in 3D mode, i.e., OpenGL rendering for that window was active?
        if IsOpenGLRendering
            % Yes. We need to switch that window back into 3D OpenGL mode:
            Screen('BeginOpenGL', previouswin);
        else
            % No. We just perform a dummy call that will switch back to that
            % window:
            Screen('GetWindowInfo', previouswin);
        end
    else
        % Our window was active beforehand.
        if IsOpenGLRendering
            % Was in 3D mode. We need to switch back to 3D:
            Screen('BeginOpenGL', previouswin);
        end
    end
end

return;
end
