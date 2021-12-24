%smoothTracking

%INPUT: Tracking, Params
%OUTPUT: Tracking

%FUNCTION: apply smoothing to data from Tracking

function Tracking = smoothTracking_custom(Tracking, Params)
    % Smooth data using smooth() function
    % time = time stamps of position data
    % ux, uy = position data

    smoothMethod = Params.Smoothing.method;
    smoothSpan = Params.Smoothing.span;
    part_names = Params.part_names;

    
    for i = 1:length(part_names)
        i_part = part_names{i};
        time = (1:size(Tracking.Raw.(i_part), 2))';
        ux = Tracking.Raw.(i_part)(1,:)';
        uy = Tracking.Raw.(i_part)(2,:)';
        x = smooth(ux, smoothSpan, smoothMethod);
        y = smooth(uy, smoothSpan, smoothMethod);
        Tracking.Smooth.(i_part) = [x,y]';
        
        % find NaNs that remain after smoothing and interpolate missing
        % data
        Tracking.Smooth.(i_part)(1,:) = fillmissing(Tracking.Smooth.(i_part)(1,:), 'spline');
        Tracking.Smooth.(i_part)(2,:) = fillmissing(Tracking.Smooth.(i_part)(2,:), 'spline');
    end

    disp(['Data smoothed using ', smoothMethod, ' method and stored in Tracking.Smooth']);
end