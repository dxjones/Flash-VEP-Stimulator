% Param.m

function Param(action)

global P;

switch action
    case 'create'
        P = [];
        P.Debug = false;            % true, false
        P.BlackLevel = 0;           % 0 .. 255
        P.WhiteLevel = 255;         % 0 .. 255
        P.Frequency = 2;            % Hz
        P.Duration = 20;            % seconds
        P.Delay = 5;                % seconds
        
        %% calculated values
        P.Period = 1 / P.Frequency; % seconds
end

end

