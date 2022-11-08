% P_calculateFreezing_velocity

%PARAMS:
% 1) velocityThreshold (cm/sec)
% 2) angleThreshold (degrees/sec)
% 3) windowWidth (frames, empirically determined)
% 4) countThreshold (arbitrary, empirically determined)
% 5) minDuration (sec)

function Params = P_calculateFreezing_velocity()

    Params.Freezing.velocityThreshold = 0.52; % Set max forward velocity
    Params.Freezing.angleThreshold = 12; % Set max angular velocity
    Params.Freezing.windowWidth = 32; % Set convolution window width 
    Params.Freezing.countThreshold = 10; % Set post-convolution count min threshold
    Params.Freezing.minDuration = 0.9; % Set min duration of behavior bout

end

