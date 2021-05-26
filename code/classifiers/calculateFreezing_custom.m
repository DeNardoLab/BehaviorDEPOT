%calculateFreezing

%INPUT: Metrics structure
%OUTPUT: Behavior.Freezing structure

%FUNCTION: calculate the freezing frames via transformation of data from
%the Metrics structure and save into Behavior structure

% Future: Calculate average velocity of body; features_list in place of
% RearBackVelocity

function Freezing = calculateFreezing_custom(Metrics, Params)    

% choose which freezing detector to use based on frame rate
% under 40 fps uses jitter; above 40 uses velocity

if Params.Video.frameRate < 40
    try
        parameters = [Metrics.Velocity.Left_Ear; Metrics.Velocity.Nose; Metrics.Velocity.Right_Ear];
    catch
        error('Cannot classify freezing. Standard FPS (< 40 FPS) freezing classifier requires Nose, Tailbase, and Head (or Ears) to be tracked');
    end
    
    
     % apply jitter threshold
     % find points at which the mean of the data changes most significantly
     % MinThreshold = minimum residual error improvement
    changethresh = 10*(1/Params.Freezing.sensitivityGain);
    [numframes, features] = size(parameters);
    for bp = 1:features
        features_list = parameters(:,bp);        
        %ipt = findchangepts(features_list,'statistic','mean','MinThreshold',100000); 
        ipt = findchangepts(features_list,'statistic','mean','MinThreshold',changethresh); 
        dipt = diff(ipt);
        consider = find(dipt > (Params.Freezing.minDuration * Params.Video.frameRate)); % identify frames where jitter is stable for more than 1sec 
        for cc = 1:length(consider)
            considerpt = consider(cc);
            long_start(cc) = ipt(considerpt);
            long_end(cc) = ipt(considerpt+1);
            if isempty(cc)
                continue
            end                
        end
        while ~isempty(cc)
            for tt = 1:length(consider)
                jitter_var(tt) = mean(features_list(long_start(tt):long_end(tt)));
            end
            if ~isempty(jitter_var)
                jitter(bp) = std(jitter_var)*1 + mean(jitter_var) * 0.75; % threshold per body point 
            else
                jitter(bp) = 0;
            end
            freeze = parameters(:,1) < jitter(1) & ...
                parameters(:,2) < jitter(2) & ...
                parameters(:,3) < jitter(3) & ...
                abs(Metrics.Diff.HeadAngle)' < (Params.Freezing.angleThreshold); % freezing == 1, no freezing == 0
            % Mark freezing
            f_start = strfind(freeze, [0 1]) + 1;
            f_end = strfind(freeze, [1 0]);
            withinFreezingThreshold = freeze;
        end
    end
    if isempty(cc)
        Freezing.Bouts = [];
        Freezing.Count = [];
        Freezing.Length = [];
        Freezing.Vector = zeros(numframes,1);
        withinFreezingThreshold = [];
        disp(Params.Video.name);
    end
else
    numframes = length(Metrics.Velocity.Head);
    try
        try
            % Velocity based freezing detector
            withinFreezingThreshold = (nanmean([Metrics.Velocity.Head;Metrics.Velocity.RearBack]) < Params.Freezing.velocityThreshold) & (abs(Metrics.Diff.HeadAngle) < Params.Freezing.angleThreshold);
            
        catch
            withinFreezingThreshold = (nanmean([Metrics.Velocity.Head;Metrics.Velocity.Tailbase]) < Params.Freezing.velocityThreshold) & (abs(Metrics.Diff.HeadAngle) < Params.Freezing.angleThreshold);
        end
    catch
        disp('Error with freezing classifer. High FPS videos (> 40 FPS) require Head (or Ears + Nose) and Legs (or Tailbase or RearBack) to be tracked');
        Freezing.Bouts = [];
        Freezing.Count = [];
        Freezing.Length = [];
        Freezing.Vector = zeros(numframes,1);
        withinFreezingThreshold = [];
    end
end

if ~isempty(withinFreezingThreshold)
    % convolve individual bouts to smooth over falsely non-contiguous
    % freezing bout detections
    freeze_counts = conv(withinFreezingThreshold, ones(1, Params.Freezing.windowWidth), 'same');
    freezingInds = freeze_counts >= Params.Freezing.countThreshold;
    freezingInds_end = freeze_counts >= round(Params.Freezing.countThreshold/2);
    freezingInds_end(1:round(numframes-1.8*Params.Freezing.windowWidth)) = 0;
    freezingInds = freezingInds | freezingInds_end;

    % Remove events cut off by the start/end of the video
    if freezingInds(length(freezingInds)) == 1
        %freezingIndices(freezingDiffIndices(end):length(freezingIndices)) = 0;
        freezingInds(length(freezingInds)) = 0;
    end
    if freezingInds(1) == 1
        %freezingIndices(1:freezingDiffIndices(1)) = 0;
        freezingInds(1) = 0; 
    end

    % find freeze start and end indices
    freezingDiff = diff(freezingInds);
    freezingDiffInds = find(freezingDiff);    
    
    freezeStart = zeros(1, round(length(freezingDiffInds)/2));
    freezeEnd = zeros(1, round(length(freezingDiffInds)/2));

    jj = 1; kk = 1;
    for i=1:length(freezingDiffInds)
        if freezingDiff(freezingDiffInds(i)) == 1
            freezeStart(jj) = freezingDiffInds(i);
            jj = jj+1;
        elseif freezingDiff(freezingDiffInds(i)) == -1
            freezeEnd(kk) = freezingDiffInds(i);
            kk = kk+1;
        end
    end

    % Adjust minimum freezing duration
    % LOOK HERE FOR POOR 
    if exist('freezeStart', 'var')
        if length(freezeStart) > length(freezeEnd)
            freezeStart = freezeStart(1:end-1);
        end
      for i = 1:length(freezeStart)
         if freezeEnd(i) - freezeStart(i) < round(Params.Video.frameRate .* Params.Freezing.minDuration) %set the minimum duration here
             freezingInds(freezeStart(i):freezeEnd(i)) = 0;
             freezeStart(i) = NaN; freezeEnd(i) = NaN;
         end
      end
    end

    freeze_inds_to_delete = find(isnan(freezeStart));
    freezeStart(freeze_inds_to_delete) = [];
    freezeEnd(freeze_inds_to_delete) = [];

    Freezing.Bouts = [];

    for i = 1:length(freezeStart)
    Freezing.Bouts(i, 1) = freezeStart(i);
    Freezing.Bouts(i, 2) = freezeEnd(i);
    end

    Freezing.Count = size(Freezing.Bouts,1);
    Freezing.Length = freezeEnd - freezeStart;
    Freezing.Vector = zeros(numframes,1);

    %Binarized vector of freezing
    for i = 1:Freezing.Count
        Freezing.Vector(Freezing.Bouts(i,1):Freezing.Bouts(i,2)) = 1;
    end
end
end