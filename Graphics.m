% Graphics.m

function Graphics(action, exception)

global P G;

% actual LCD or CRT FrameRate measured using FrameRate.m
% table used to convert PTB Hz to actual Hz
% PTB returns 0 Hz for LCD
FrameRateTable = [ ...
      0      59.952 ; ...
    100     100.559 ; ...
    ];

switch action
    case 'create'
        G = [];
        G.whichScreen = max(Screen('Screens'));
        res = Screen('Resolution', G.whichScreen);
        G.FrameRate = res.hz;

        % if FrameRate is in Table, substitute measured value
        X = find(FrameRateTable(:,1) == G.FrameRate);
        if ~isempty(X)
            G.FrameRate = FrameRateTable(X,2);
        end
        
        G.FramePeriod = 1 / G.FrameRate;
        
        % warn if stimulus frequency does not evenly divide display frequency
        if mod(G.FrameRate, P.Frequency) > 0.001
            fprintf('\nWARNING: Stimulus Frequency (%.3f Hz) does not evenly divide Display Frequency (%.3f Hz)\n', P.Frequency, G.FrameRate);
            P.Period = round(P.Period / G.FramePeriod) * G.FramePeriod;
            P.Frequency = 1 / P.Period;
            fprintf('Adjusted Stimulus Frequency = %.3f Hz\n', P.Frequency);
        end
        
        % initialize these, just in case there is a PTB exception
        % ... in which case, we invoke Graphics('error'), Graphics('end')
        
        G.oldPriority = 0;
        G.oldSkipSyncTests = 0;
        G.oldVisualDebugLevel = 3;
        G.oldSuppressAllWarnings = 0;
        G.oldVerbosity = 1;
        
        
    case 'begin'
        if P.Debug
            G.oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 0);
            G.oldVerbosity = Screen('Preference', 'Verbosity', 4);
            G.oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 0);
            G.oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 4);
        else
            G.oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 1);
            G.oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
            G.oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
            G.oldVerbosity = Screen('Preference', 'Verbosity', 1);
        end
        G.oldPriority = Priority(9);
        HideCursor;
        G.window = Screen('OpenWindow', G.whichScreen);
        Screen('FillRect', G.window, 0);
        Screen('Flip', G.window);
        
    case 'end'
        Screen('CloseAll');
        ShowCursor;
        Priority(G.oldPriority);
        Screen('Preference', 'SkipSyncTests', G.oldSkipSyncTests);
        Screen('Preference', 'VisualDebugLevel', G.oldVisualDebugLevel);
        Screen('Preference', 'SuppressAllWarnings', G.oldSuppressAllWarnings);
        Screen('Preference', 'Verbosity', G.oldVerbosity);

    case 'error'
        fprintf('\n[ caught PTB error ]\n');
        Key('end');
        Graphics('end');
%         fprintf('%s\n', getReport(exception, 'extended'));
        rethrow(exception);
end

end
