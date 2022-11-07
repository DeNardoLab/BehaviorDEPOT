% BehaviorDEPOT Classifier Template
% C.G. 1/04/22
% Contact: cjgabrie@ucla.edu

%FUNCTION: calculate the freezing frames via transformation of data from
%the Metrics structure and save into Behavior structure

%PARAMS:
% 1) your1stChosenThreshold
% 2) your2ndChosenThreshold
% 3) yourNthChosenThreshold
% 4) windowWidth (frames, empirically determined)
% 5) countThreshold (arbitrary, empirically determined)
% 6) minDuration (sec)
% 7) maxDuration (sec)

% Each classifier in a MATLAB function that is run during the mainscript.
% The name of your classifier (e.g. calculateBehavior) should indicate what
% behavior it classifies and should be distinct if creating multiple
% classifiers for the same behavior (e.g. calculateFreezing_velocity &
% calculateFreezing_jitter)

% The output of the function (e.g. BehaviorName) is a MATLAB structure containing the bout-wise and vectorized behavior data.
% This structure should be named for the behavior classified. This must
% match the name in the associated 'P_' file

% The inputs for the classifier file should not be changed and can be left
% as is (e.g. Params, Tracking, Metrics; in that order)

function BehaviorName = calculateBehavior(Params, Tracking, Metrics)    

    %% Select the thresholds for the behavior you wish to capture:
    % You may set any number of different thresholds that work with your behavior-of-interest.
    % The thresholds themselves are set in the associated 'P_' file
    first_threshold = Params.BehaviorName.your1stChosenThreshold;
    second_threshold = Params.BehaviorName.your2ndChosenThreshold;
    nth_threshold = Params.BehaviorName.yourNthChosenThreshold;
    
    %% Apply thresholds to relevant data from Metrics
    % Thresholds shown here are examples meant to illustrate usage
    
    % Threshold 1: Head velocity above first_threshold 
    within_first_threshold = Metrics.Velocity.Head > first_threshold;
    
    % Threshold 2: Nose-tailbase distance below second_threshold
    within_second_threshold = Metrics.Dist.NoseTailbase < second_threshold;
    
    % Threshold N: Only collect frames after mouse has traveled at least nth_threshold
    within_nth_threshold = Metrics.Movement.DistanceTraveled > nth_threshold;
    
    %% Combine applied thresholds to find raw behavior frames
    % NOTE: you can use logical operators, (& --> and, | --> or) 
    %       in any combination to apply thresholds 
    withinBehaviorThreshold = within_first_threshold &...
                              within_second_threshold &...
                              within_nth_threshold;
    
    %% Convolve raw behavior frames to smooth behavior labeling
    % Units for windowWidth and countThreshold is frames (not seconds)
    
    % In our hands, windowWidth is usually best at around the size of
    % the smallest behavior bout you wish to detect
    
    % countThreshold can vary more from behavior-to-behavior; however, ~1/3
    % the value of the windowWidth is usually a decent value
    smoothed_frames = convolveFrames(withinBehaviorThreshold, Params.BehaviorName.windowWidth, Params.BehaviorName.countThreshold);
    
    %% Collect list of start/stop inds from post-convolution vector
    [behavior_start_inds, behavior_stop_inds] = findStartStop(smoothed_frames);
    
    %% Apply minimum duration threshold to start/stop inds
    % Units for Params.BehaviorName.minDuration is in seconds (not frames)
    [behavior_start_inds, behavior_stop_inds] = applyMinThreshold(behavior_start_inds, behavior_stop_inds, Params.BehaviorName.minDuration, Params);

    %% Apply maximum duration threshold to start/stop inds
    % Units for Params.BehaviorName.maxDuration is in seconds (not frames)
    
    %% Generate behavior structure
    % This function will package the final data into a structure for output
    % Be sure to change 'BehaviorName' to your behavior both here and at
    % the function call line (at the top)
    BehaviorName = genBehStruct(behavior_start_inds, behavior_stop_inds, Params.numFrames);
end