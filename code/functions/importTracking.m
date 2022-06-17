function [data, Params] = importTracking(Params)

% Check if H5 file, then check if DLC or SLEAP and run appropriate import
% function
if strcmp(Params.tracking_fileType, 'h5')
    % Insert pseudocode for identifying SLEAP H5 header
    if isSLEAPh5(Params.tracking_file)
        track_type = 'sleap';
    else 
        track_type = 'dlc';
    end

else
    track_type = 'dlc';
end

% Save track_type to Params
Params.track_type = track_type;

% Run appropriate import function
if strcmp(track_type, 'dlc')
    [data, Params] = importDLCTracking(Params);
elseif strcmp(track_type, 'sleap')
    [data, Params] = importSLEAPTracking(Params);
end

end