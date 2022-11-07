function [start_inds, stop_inds] = applyMaxThreshold(start_inds, stop_inds, maxDuration, Params)

    % Adjust maximum duration
    if length(start_inds) > length(stop_inds)
        start_inds = start_inds(1:end-1);
    end
    
    for i = 1:length(start_inds)
        if stop_inds(i) - start_inds(i) > round(Params.Video.frameRate .* maxDuration) %set the minimum duration here
            start_inds(i) = NaN; stop_inds(i) = NaN;
        end
    end
    
    inds_to_delete = find(isnan(start_inds));
    start_inds(inds_to_delete) = [];
    stop_inds(inds_to_delete) = [];
    
end