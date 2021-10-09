% P_calculateEscape

%PARAMS:
% 1) minVelocity (cm/sec)
% 2) minDuration (sec)

function Params = P_calculateEscape()

    Params.Escape.minVelocity = 0.52; % Set max forward velocity
    Params.Escape.minDuration = 0.9; % Set min duration of behavior bout

end