%calculateFreezing_velocity
% C.G. 8/25/21
% Contact: cjgabrie@ucla.edu

%INPUT: Metrics, Params
%OUTPUT: Freezing structure

%FUNCTION: calculate the freezing frames via transformation of data from
%the Metrics structure and save into Behavior structure

%PARAMS:
% 1) velocityThreshold (cm/sec)
% 2) angleThreshold (degrees/sec)
% 3) windowWidth (frames, empirically determined)
% 4) countThreshold (arbitrary, empirically determined)
% 5) minDuration (sec)

function Freezing = calculateFreezing_velocity(Params, Tracking, Metrics)    

    velocityThreshold = Params.Freezing.velocityThreshold;
    angleThreshold = Params.Freezing.angleThreshold;

    % Appy thresholds to velocity data
    try
        % Collect frames falling below forward & angular velocity thresholds
        try
            % First attempt: Average head and rear back velocities
            withinFreezingThreshold = (nanmean([Metrics.Velocity.Head;Metrics.Velocity.RearBack]) < velocityThreshold)...
                                    & (abs(Metrics.Velocity.HeadAngle) < angleThreshold);
        catch
            % Second attempt: Average head and tailbase velocities
            withinFreezingThreshold = (nanmean([Metrics.Velocity.Head;Metrics.Velocity.Tailbase]) < velocityThreshold)...
                                    & (abs(Metrics.Velocity.HeadAngle) < angleThreshold);
        end
    catch
        disp('Error with freezing classifer. Velocity classifier requires Head (i.e. Ears + Nose) and RearBack (or Tailbase) to be tracked');
    end

    % Apply convolution for smoothing
    freezingFrames = convolveFrames(withinFreezingThreshold, Params.Freezing.windowWidth, Params.Freezing.countThreshold);
    
    % Collect list of start/stop inds from post-convolution vector
    [freezeStart, freezeStop] = findStartStop(freezingFrames);
    
    % Apply minimum velocity threshold
    [freezeStart, freezeStop] = applyMinThreshold(freezeStart, freezeStop, Params.Freezing.minDuration, Params);

    % Generate behavior structure
    Freezing = genBehStruct(freezeStart, freezeStop, Params.numFrames);
end