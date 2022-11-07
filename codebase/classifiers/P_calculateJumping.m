% P_calculateJumping

%PARAMS:
% 1) minVelocity (cm/sec)
% 5) minDuration (sec)

function Params = P_calculateJumping()

    Params.Jumping.minVelocity = 30; % Set min forward velocity
    Params.Jumping.minDuration = 0.1; % Set min duration of behavior bout

end