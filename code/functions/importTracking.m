function [data, Params] = importTracking(Params)

% Save track_type to Params
track_type = Params.tracking_type;

% Run appropriate import function
if contains(track_type, 'dlc')
    [data, Params] = importDLCTracking(Params);
elseif contains(track_type, 'sleap')
    [data, Params] = importSLEAPTracking(Params);
end
end