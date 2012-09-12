% FlashStim.m

fprintf('\nFlashStim 1.0\n');
global P G K;

Key('create');
Graphics('create');
Param('create');
fprintf('\nParameters:\n');
fprintf('\tFlash Frequency = %.2f Hz\n', P.Frequency);
fprintf('\tDelay Before/After Stimulus = %d seconds\n', P.Delay);
fprintf('\tStimulus Duration = %d seconds\n', P.Duration);
fprintf('\nto begin, press SPACE ...\n');

frameCount = 0;
frameMax = 0;
try   
    Key('begin');
    if Key('space') == -1
        fprintf('[ escape ]\n');
    else
        fprintf('\nOK\n\n');
        WaitSecs(1);

        Graphics('begin');
        WaitSecs(P.Delay);
        Screen('FillRect', G.window, P.BlackLevel);
        start = GetSecs;
        stop = start + P.Duration;
        escape = false;
        frameDelay = 0;
        while 1
            if P.debug
                fprintf('Frame %3d\n', frameCount);
            end
            Screen('FillRect', G.window, P.WhiteLevel);
            t1 = Screen('Flip', G.window);
            Screen('FillRect', G.window, P.BlackLevel);
            t2 = Screen('Flip', G.window);
            delta = t2 - t1;
            if delta > frameMax, frameMax = delta; end
            frameDelay = frameDelay + delta;
            frameCount = frameCount + 1;
            if Key('escape') == -1
                fprintf('[ escape ]\n');
                escape = true;
                break
            end
            WaitSecs('UntilTime', start + frameCount*P.Period);
            if GetSecs >= stop
                break
            end
        end
        if ~escape
            WaitSecs(P.Delay);
        end
        Graphics('end');
    end
    Key('end');

catch e
    Graphics('error', e);
end

if frameCount > 0
    frameDelay = frameDelay / frameCount;
    fprintf('Max Frame Delay = %.3f msec\n', frameMax*1000);
    fprintf('Avg Frame Delay = %.3f msec\n', frameDelay*1000);
end
