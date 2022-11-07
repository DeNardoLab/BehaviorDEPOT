% P_calculateFreezing_jitter

function Params = P_calculateFreezing_jitter()

%PARAMS:
% 1) sensitivityGain
% 2) angleThreshold (degrees/sec)
% 3) windowWidth (frames, empirically determined)
% 4) countThreshold (arbitrary, empirically determined)
% 5) minDuration (sec)

Params.Freezing.sensitivityGain = 1; % Set max forward velocity
Params.Freezing.angleThreshold = 12; % Set max angular velocity
Params.Freezing.windowWidth = 32; % Set convolution window width 
Params.Freezing.countThreshold = 10; % Set post-convolution count min threshold
Params.Freezing.minDuration = 0.9; % Set min duration of behavior bout

end