%calculateFreezing_jitter

%INPUT: Metrics, Params
%OUTPUT: Freezing structure

%FUNCTION: calculate the freezing frames via transformation of data from
%the Metrics structure and save into Behavior structure

%PARAMS:
% 1) sensitityGain (arbitrary)
% 2) angleThreshold (degrees/sec)
% 3) windowWidth (frames, empirically determined)
% 4) countThreshold (arbitrary, empirically determined)
% 5) minDuration (sec)

function Freezing = calculateFreezing_jitter(Params, Tracking, Metrics)

    sensitivityGain = Params.Freezing.sensitivityGain;
    angleThreshold = Params.Freezing.angleThreshold;
    
    try
        part_list = [Metrics.Velocity.Head; Metrics.Velocity.Nose; Metrics.Velocity.Tailbase]';
    catch
        error('Cannot classify freezing. Jitter freezing classifier requires Nose, Tailbase, and Head (i.e. Nose + Ears) to be tracked');
    end

    % apply jitter threshold
    % find points at which the mean of the data changes most significantly
    % MinThreshold = minimum residual error improvement
    changethresh = 10*(1/sensitivityGain);
    
    for bp = 1:size(part_list, 2)
        
        test = part_list(:,bp);        
        ipt = findchangepts(test,'statistic','mean','MinThreshold',changethresh); 
        dipt = diff(ipt);
        consider = find(dipt > (Params.Freezing.minDuration * Params.Video.frameRate)); % identify frames where jitter is stable for more than minDuration 
        
        for cc = 1:length(consider)
            considerpt = consider(cc);
            long_start(cc) = ipt(considerpt);
            long_end(cc) = ipt(considerpt+1);
        end
        
        for tt = 1:length(consider)
            bites(tt) = mean(test(long_start(tt):long_end(tt)));
        end
        
        if ~isempty(bites)
            jitter(bp) = std(bites)*1 + mean(bites) * 0.75; % threshold per body point 
        else
            jitter(bp) = 0;
        end
    end

    % freezing == 1, no freezing == 0
    freeze = part_list(:,1) < jitter(1) & ...
             part_list(:,2) < jitter(2) & ...
             part_list(:,3) < jitter(3) & ...
             abs(Metrics.Diff.HeadAngle)' < (angleThreshold); 
        
    % Initial candidates for freezing frames
    withinFreezingThreshold = freeze';

    % Apply convolution for smoothing
    freezingFrames = convolveFrames(withinFreezingThreshold, Params.Freezing.windowWidth, Params.Freezing.countThreshold);
    
    % Collect list of start/stop inds from post-convolution vector
    [freezeStart, freezeStop] = findStartStop(freezingFrames);
    
    % Apply minimum velocity threshold
    [freezeStart, freezeStop] = applyMinThreshold(freezeStart, freezeStop, Params.Freezing.minDuration, Params);

    % Generate Behavior Structure
    Freezing = genBehStruct(freezeStart, freezeStop, Params.numFrames);

end