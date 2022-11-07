%% calculateJumping
  
% INPUTS: Params, Metrics
% OUTPUT: Jumping

% PARAMS:
% 1) minVelocity
% 2) minDuration

function Jumping = calculateJumping(Params, Tracking, Metrics)
  
    minVelocity = Params.Jumping.minVelocity;
    minDuration = Params.Jumping.minDuration;

    body_velocity = nanmean([Metrics.Velocity.Head; Metrics.Velocity.RearBack]);
    jumping_velocity_nans = isnan(body_velocity);
    jumping_velocity_data = ~jumping_velocity_nans;
    jumping_nan_inds = find(jumping_velocity_nans);
    chunk_start_inds = find(diff(jumping_nan_inds) > 1);

    if sum(jumping_velocity_nans) == 0
        jumping_envelope = envelope(body_velocity, 8, 'peak');
        [jumping_peaks, jumping_peak_inds] = findpeaks(jumping_envelope, 'MinPeakHeight', minVelocity);
        [jumping_troughs, jumping_trough_inds] = findpeaks(-jumping_envelope);
    elseif sum(diff(jumping_nan_inds)) == length(jumping_nan_inds)-1
        jumping_chunk1_inds = [1: jumping_nan_inds(1)-1];
        jumping_chunk2_inds = [jumping_nan_inds(end)+1: length(body_velocity)];
        jumping_envelope1 = envelope(body_velocity(jumping_chunk1_inds), 8, 'peak');
        jumping_envelope2 = envelope(body_velocity(jumping_chunk2_inds), 8, 'peak');
        [jumping_peaks1, jumping_peak_inds1] = findpeaks(jumping_envelope1, 'MinPeakHeight', minVelocity);
        [jumping_troughs1, jumping_trough_inds1] = findpeaks(-jumping_envelope1);
        [jumping_peaks2, jumping_peak_inds2] = findpeaks(jumping_envelope2, 'MinPeakHeight', minVelocity);
        [jumping_troughs2, jumping_trough_inds2] = findpeaks(-jumping_envelope2);
        jumping_peak_inds2 = jumping_peak_inds2 + jumping_chunk2_inds(1);
        jumping_trough_inds2 = jumping_trough_inds2 + jumping_chunk2_inds(1);
        jumping_peak_inds = [jumping_peak_inds1, jumping_peak_inds2];
        jumping_trough_inds = [jumping_trough_inds1, jumping_trough_inds2];
    else
        disp('Jumping Chunking Error')
    end

    clear jumping_envelope1 jumping_envelope2 jumping_peaks1 jumping_peaks2 jumping_peak_inds1 jumping_peak_inds2 jumping_troughs1 jumping_troughs2 jumping_trough_inds1 jumping_trough_inds2

    %% Find index values that are part of the same behavior
    jumping_peak_diff = diff(jumping_peak_inds);

    for i = length(jumping_peak_diff): -1 : 1
        if jumping_peak_diff(i) < Params.Video.frameRate*5
            jumping_peak_inds(i) = NaN;
        end
    end

    %Remove NaN Values
    temp_nans = isnan(jumping_peak_inds);
    nan_inds = find(temp_nans);
    jumping_peak_inds(nan_inds) = [];

    jumpingStart = zeros(length(jumping_peak_inds),1);
    jumpingStop = zeros(length(jumping_peak_inds),1);

    for i = 1:length(jumping_peak_inds)
        jumpingStart(i) = jumping_trough_inds(find(jumping_trough_inds - jumping_peak_inds(i) < 0, 1, 'last'));
        jumpingStop(i) = jumping_trough_inds(find(jumping_trough_inds - jumping_peak_inds(i) > 0, 1));
    end
    
    % Apply minimum duration threshold
    [jumpingStart, jumpingStop] = applyMinThreshold(jumpingStart, jumpingStop, minDuration, Params.Video.frameRate);

    % Generate Behavior Structure
    Jumping = genBehStruct(jumpingStart, jumpingStop, Params.numFrames);

end