% FrameRate.m

fprintf('\nFrameRate\n');
clear all;
global P G;

Param('create');
Graphics('create');

try
    Graphics('begin');

    % synchronize with "frame refresh"
    Screen('Flip', G.window);

    K = 10;
    Nframes = 1000 + K;
    t = zeros(Nframes,1);
    for i = 1:Nframes
        t(i) = Screen('Flip', G.window);
    end

    Graphics('end');

catch e
    Graphics('error', e);
end

Period = (t(end) - t(K)) / (Nframes - K);
Frequency = 1 / Period;

fprintf('Frame Period =  %.9f msec\n', Period*1000);
fprintf('Frame Rate   = %.9f Hz\n', Frequency);
fprintf('\n');