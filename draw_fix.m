function [] = draw_fix(window, x, y, secs, box)
%DRAW_FIX Summary of this function goes here
%   Detailed explanation goes here

%set up text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);
%Screen('FrameRect', window, [255 255 0], [], 10)

%set size of arms for cross and line width
fixCrossDimPix = 40;
lineWidthPix = 4;

%set coordinates
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% resp indicator
if box ~= 0
    Screen('FrameRect', window, [255 255 0], [], 10);
end
%draw and flip to screen
Screen('Flip', window);

% resp indicator
if box ~= 0
    Screen('FrameRect', window, [255 255 0], [], 10);
end
Screen('DrawLines', window, allCoords, lineWidthPix, 1, [x y], 2);
Screen('Flip', window);

%clear image after certain time (if time given)
if secs ~= 0
    WaitSecs(secs);
    Screen('Flip', window);
end
end

