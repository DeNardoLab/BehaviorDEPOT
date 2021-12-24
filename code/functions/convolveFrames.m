function beh_inds = convolveFrames(data_vector, windowWidth, countThreshold)
    
    % convolve individual bouts to smooth over falsely non-contiguous bouts
    beh_counts = conv(data_vector, ones(1, windowWidth), 'same');
    beh_inds = beh_counts >= countThreshold;
    
    behInds_ends = beh_counts >= round(countThreshold/2); % Apply smaller countThreshold near beginning/end of video
    behInds_ends( (round(windowWidth) + 1) : (round(end - windowWidth) - 1) ) = 0;
    
    beh_inds = beh_inds | behInds_ends; % Collect all positive inds

end