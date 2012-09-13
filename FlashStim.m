% FlashStim.m

% Revisions:
%
% 1.2   updated variable name "flashCount" is more accurate
%       fixed problem related to Java "classpath.txt"
%       - PTB exception could occur during Key('create')
%       - solved by moving Graphics('create') before Key('create')
%       - added /Applications/Psychtoolbox/PsychJava to classpath.txt
%       added warning ...
%       - when stimulus frequency does not evenly divide display frequency
%       - requires Param('create') before Graphics('create')
%       fixed timing drift
%       - new program "FrameRate.m" measures actual CRT frame rate
%       - example: PTB reports 100 Hz, but measured rate is 100.559 Hz
%       - adjust FrameRate to match measured value
%       - adjust Stimulus Frequency, so it evenly divides FrameRate
%
% 1.1   fixed timing issue:
%       - detect FrameRate (note: PTB returns "0 Hz" for LCD)
%       - adjust to 60Hz nominal rate for LCD
%       - reduce "wait until time" by 1/2 frame time
%       - measure actual delay before 1st Flip to check for consistency
%       updated Graphics('create') so all fields in "G" are defined
%       - in case of PTB exception, ... Graphics('error'), Graphics('end')
%       added some comments in code
%
% 1.0   initial revision

clear;
fprintf('\nFlashStim 1.2\n');
global P G K;

Param('create');
Graphics('create');
Key('create');
fprintf('\nParameters:\n');
fprintf('\tFlash Frequency = %.3f Hz\n', P.Frequency);
fprintf('\tDelay Before/After Stimulus = %d seconds\n', P.Delay);
fprintf('\tStimulus Duration = %d seconds\n', P.Duration);
fprintf('\nto begin, press SPACE ...\n');

flashCount = 0;
frameDelay = 0;
frameMax = 0;
preFlipDelay = 0;
preFlipMax = 0;
try   
    Key('begin');
    escape = false;
    if Key('space') == -1
        fprintf('[ escape ]\n');
        escape = true;
    else
        fprintf('\nOK\n\n');
        WaitSecs(1);

        Graphics('begin');
        WaitSecs(P.Delay);
        
        if P.Debug
            Nframes = P.Duration * P.Frequency;
            timing = zeros(4, Nframes);
        end
        
        % synchronize with "frame refresh"
        Screen('FillRect', G.window, P.BlackLevel);
        start = Screen('Flip', G.window);
        stop = start + P.Duration;

        % wait 1/2 FramePeriod, so we always start loop in same state
        t = WaitSecs('UntilTime', start + 0.1*G.FramePeriod);
        
        while t < stop
            % should alway start loop 0.9 * FramePeriod before next Flip
            t0 = GetSecs;
            flashCount = flashCount + 1;
            
            % display White for 1 frame, then back to Black
            Screen('FillRect', G.window, P.WhiteLevel);
            t1 = Screen('Flip', G.window);
            Screen('FillRect', G.window, P.BlackLevel);
            t2 = Screen('Flip', G.window);
            
            % calculate delay before 1st Flip (to white)
            % - should be about 0.9 * FramePeriod
            delta = t1 - t0;
            if delta > preFlipMax, preFlipMax = delta; end
            preFlipDelay = preFlipDelay + delta;
            
            % calculate delay before 2nd Flip (to black)
            % - should be exactly 1 FramePeriod
            delta = t2 - t1;
            if delta > frameMax, frameMax = delta; end
            frameDelay = frameDelay + delta;
            
            if P.Debug
                timing(:,flashCount) = [ (start+(flashCount-1)*P.Period); t0; t1; t2 ] - start;
            end
            
            if Key('escape') == -1
                fprintf('[ escape ]\n');
                escape = true;
                break
            end
            
            % wait long enough to achieve desired temporal frequency
            t = WaitSecs('UntilTime', start + flashCount*P.Period + 0.1*G.FramePeriod);
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

if flashCount > 0
    preFlipDelay = preFlipDelay / flashCount;
    frameDelay = frameDelay / flashCount;
    fprintf('Flash Count = %d\n', flashCount);
    fprintf('Pre-Flip Delay, Avg = %.3f msec, Max = %.3f msec, (expected = %.3f msec)\n', preFlipDelay*1000, preFlipMax*1000, 0.9*G.FramePeriod*1000);
    fprintf('Frame Delay, Avg = %.3f msec, Max = %.3f msec, (expected = %.3f msec)\n', frameDelay*1000, frameMax*1000, G.FramePeriod*1000);
end

if P.Debug && ~escape
    Nframes = size(timing,2);
    t = 1:Nframes;
    figure(1);
    timing(2:end,:) = 1000 * (timing(2:end,:) - repmat(timing(1,:), 3,1));
    plot(t,timing(2,:), 'ro-', t,timing(3,:),'go-', t,timing(4,:),'bo-');
    title('Timing Info (for debugging)');
    xlabel('Frame Number');
    ylabel('Delay (msec)');
end

