%% calculateEscape
  
% INPUTS: Params, Metrics
% OUTPUT: Escape

% PARAMS:
% 1) minVelocity
% 2) minDuration

function Escape = calculateEscape(Params, Tracking, Metrics)
  
    minVelocity = Params.Escape.minVelocity;
    minDuration = Params.Escape.minDuration;

    try
        body_velocity = nanmean([Metrics.Velocity.Head; Metrics.Velocity.RearBack]);
    catch
        body_velocity = nanmean([Metrics.Velocity.Head; Metrics.Velocity.Tailbase]);
    end
    
    escape_velocity_nans = isnan(body_velocity);
    escape_velocity_data = ~escape_velocity_nans;
    escape_nan_inds = find(escape_velocity_nans);
    chunk_start_inds = find(diff(escape_nan_inds) > 1);

    if sum(escape_velocity_nans) == 0
        escape_envelope = envelope(body_velocity, 8, 'peak');
        [escape_peaks, escape_peak_inds] = findpeaks(escape_envelope, 'MinPeakHeight', minVelocity);
        [escape_troughs, escape_trough_inds] = findpeaks(-escape_envelope);
    elseif sum(diff(escape_nan_inds)) == length(escape_nan_inds)-1
        escape_chunk1_inds = [1: escape_nan_inds(1)-1];
        escape_chunk2_inds = [escape_nan_inds(end)+1: length(body_velocity)];
        escape_envelope1 = envelope(body_velocity(escape_chunk1_inds), 8, 'peak');
        escape_envelope2 = envelope(body_velocity(escape_chunk2_inds), 8, 'peak');
        [escape_peaks1, escape_peak_inds1] = findpeaks(escape_envelope1, 'MinPeakHeight', minVelocity);
        [escape_troughs1, escape_trough_inds1] = findpeaks(-escape_envelope1);
        [escape_peaks2, escape_peak_inds2] = findpeaks(escape_envelope2, 'MinPeakHeight', minVelocity);
        [escape_troughs2, escape_trough_inds2] = findpeaks(-escape_envelope2);
        escape_peak_inds2 = escape_peak_inds2 + escape_chunk2_inds(1);
        escape_trough_inds2 = escape_trough_inds2 + escape_chunk2_inds(1);
        escape_peak_inds = [escape_peak_inds1, escape_peak_inds2];
        escape_trough_inds = [escape_trough_inds1, escape_trough_inds2];
    else
        disp('Escape Chunking Error')
    end

    clear escape_envelope1 escape_envelope2 escape_peaks1 escape_peaks2 escape_peak_inds1 escape_peak_inds2 escape_troughs1 escape_troughs2 escape_trough_inds1 escape_trough_inds2

    %% Find index values that are part of the same behavior
    escape_peak_diff = diff(escape_peak_inds);

    for i = length(escape_peak_diff): -1 : 1
        if escape_peak_diff(i) < Params.Video.frameRate*5
            escape_peak_inds(i) = NaN;
        end
    end

    %Remove NaN Values
    temp_nans = isnan(escape_peak_inds);
    nan_inds = find(temp_nans);
    escape_peak_inds(nan_inds) = [];

    escapeStart = zeros(length(escape_peak_inds),1);
    escapeStop = zeros(length(escape_peak_inds),1);

    for i = 1:length(escape_peak_inds)
        escapeStart(i) = escape_trough_inds(find(escape_trough_inds - escape_peak_inds(i) < 0, 1, 'last'));
        escapeStop(i) = escape_trough_inds(find(escape_trough_inds - escape_peak_inds(i) > 0, 1));
    end
    
    % Apply minimum duration threshold
    [escapeStart, escapeStop] = applyMinThreshold(escapeStart, escapeStop, minDuration, Params.Video.frameRate);

    % Generate Behavior Structure
    Escape = genBehStruct(escapeStart, escapeStop, Params.numFrames);

end