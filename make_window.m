function [window, windowRect, windowData] = make_window(full)
%MAKE_WINDOW Summary of this function goes here
%   Detailed explanation goes here

%clear workspace and screen
sca;
close all;

%call default settings
PsychDefaultSetup(2);

%get screen numbers
screens = Screen('Screens');

%get max of these, for external monitor
screenNumber = max(screens);

%define white and black values, 0 to 1 
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = white/2;

if full==1
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);

else
    startX = 120;
    startY = 50;
    dimX = 400;
    dimY = 250;
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray,...
        [startX startY startX+dimX startY+dimY], [], [], [], [], [],...
        kPsychGUIWindow);
end

%set up blending for smooth lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%get a bunch of info about the window
rect = Screen('Rect', window); %gets [xL, yT, xR, yB]
[screenXpix, screenYpix] = Screen('WindowSize', window); %gets [xR, yB]
[xCent, yCent] = RectCenter(windowRect); %gets [xR/2, yB/2]
ifi = Screen('GetFlipInterval', window); %gets min draw time
hertz = FrameRate(window); %gets refresh rate, =1/ifi
nominalHz = Screen('NominalFrameRate', window); %fr as reported by video card
pixSize = Screen('PixelSize', window); %color depth in bits
[w, h] = Screen('DisplaySize', screenNumber); %display size in mm
maxLum = Screen('ColorRange', window); % max coded luminance level 

windowData.rect = rect;
windowData.screenXpix = screenXpix;
windowData.screenYpix = screenYpix;
windowData.xCent = xCent;
windowData.yCent = yCent;
windowData.ifi = ifi;
windowData.hertz = hertz;
windowData.nominalHz = nominalHz;
windowData.pixSize = pixSize;
windowData.w = w;
windowData.h = h;
windowData.maxLum = maxLum;

end