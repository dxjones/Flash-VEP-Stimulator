% Graphics.m

function Graphics(action, exception)

global P G;

switch action
    case 'create'
        G = [];
        G.whichScreen = max(Screen('Screens'));
        
    case 'begin'
        if P.debug
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
