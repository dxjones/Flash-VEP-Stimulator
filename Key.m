% Key.m

function code = Key(action, timeout)

global P K;

% -3    unknown
% -2    timeout
% -1    escape
% 0     initiate trial
% 1     vertical
% 2     horizontal
% 3     repeat trial
% 4     less noise
% 5     more noise
% 6     timeout
% 7     previous level
% 8     next level
% 9     unknown

code = -3;  % unknown
switch action
    case 'create'
        K = [ ...
            -1, KbName('escape'); ...
            0, KbName('0'); ...
            0, KbName('0)'); ...
            0, KbName('space'); ...
            1, KbName('1'); ...
            1, KbName('1!'); ...
            1, KbName('uparrow'); ...
            1, KbName('downarrow'); ...
            2, KbName('2'); ...
            2, KbName('2@'); ...
            2, KbName('leftarrow'); ...
            2, KbName('rightarrow'); ...
            3, KbName('3'); ...
            3, KbName('3#'); ...
            3, KbName('='); ...
            3, KbName('=+'); ...
            4, KbName('4'); ...
            4, KbName('4$'); ...
            5, KbName('5'); ...
            5, KbName('5%'); ...
            6, KbName('6'); ...
            6, KbName('6^'); ...
            7, KbName('7'); ...
            7, KbName('7&'); ...
            8, KbName('8'); ...
            8, KbName('8*'); ...
            9, KbName('9'); ...
            9, KbName('9('); ...
           ];

    case 'begin'
        ListenChar(2);
        while KbCheck; end
        FlushEvents('keyDown');

    case 'wait'
        if exist('timeout','var')
            startSecs = GetSecs;
        else
            timeout = 0;
        end
        while 1
            [keyPress timeSecs keyCode] = KbCheck;
            if (timeout > 0) && ((timeSecs - startSecs) > timeout)
                fprintf('timeout\n');
                code = -2;   % "timeout"
                break
            end
            if keyPress
                while KbCheck; end
                FlushEvents('keyDown');
                for i = 1:size(K,1)
                    if keyCode(K(i,2))
                        code = K(i,1);
                        break
                    end
                end
                if P.debug
                    fprintf('[ code = %d ]\n', code);
                end
                break
            end
        end
        
    case 'space'
        if ~exist('timeout','var')
            timeout = 0;
        end
        while 1
            code = Key('wait', timeout);
            if code == 0 || code == -1 || code == -2
                break
            end
        end

    case 'escape'
        [keyPress timeSecs keyCode] = KbCheck;
        if keyPress           
            % DO NOT wait for key to be released
            % while KbCheck; end
            FlushEvents('keyDown');
            if keyCode(KbName('escape'))
                code = -1;
            end
        end
        
    case 'end'
        ListenChar(1);
end

end

