% P_calculateJumping

%PARAMS:
% 1) minVelocity (cm/sec)
% 5) minDuration (sec)

function Params = P_calculateJumping()

    Params.Jumping.minVelocity = 0.52; % Set max forward velocity
    Params.Jumping.minDuration = 0.9; % Set min duration of behavior bout

end