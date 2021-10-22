% P_calculateMoving

%PARAMS:
% 1) minVelocity (cm/sec)
% 2) minDuration (sec)

function Params = P_calculateMoving()

    Params.Moving.minSpeed = 1; % Set max forward velocity
    Params.Moving.minDuration = 0.1; % Set min duration of behavior bout

end