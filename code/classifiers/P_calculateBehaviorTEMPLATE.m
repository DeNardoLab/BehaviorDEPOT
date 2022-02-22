% P_calculateBehaviorTEMPLATE
% C.G. 1/04/22
% Contact: cjgabrie@ucla.edu

%PARAMS:
% 1) your1stChosenThreshold
% 2) your2ndChosenThreshold
% 3) yourNthChosenThreshold
% 4) windowWidth (frames, empirically determined)
% 5) countThreshold (arbitrary, empirically determined)
% 6) minDuration (sec)
% 7) maxDuration (sec)

% 'BehaviorName' must match name in associated classifier file
% Can set any number of parameters, as needed

% Thresholds below are chosen to illustrate how to choose threshold and are
% not necessarily tuned for a particular behavior

function Params = P_calculateBehaviorTEMPLATE()
    
    % Threshold 1: Head velocity above first_threshold 
    Params.BehaviorName.your1stChosenThreshold = 0.5; % In cm/sec
    
    % Threshold 2: Nose-tailbase distance below second_threshold
    Params.BehaviorName.your2ndChosenThreshold = 5.6; % In centimeters
    
    % Threshold N: Only collect frames after mouse has traveled at least nth_threshold
    Params.BehaviorName.yourNthChosenThreshold = 20; % In centimeters
    
    % windowWidth (in frames, empirically determined; used for convolution)
    Params.BehaviorName.windowWidth = 32;
    
    % countThreshold (arbitrary units, empirically determined; used for convolution)
    Params.BehaviorName.countThreshold = 10;
    
    % minDuration (sec) of behavior bout
    Params.BehaviorName.minDuration = 0.9;
    
    % maxDuration (sec) of behavior bout
    Params.BehaviorName.maxDuration = 30; 

end