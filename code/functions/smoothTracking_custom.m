%smoothTracking

%INPUT: Tracking, Params
%OUTPUT: Tracking

%FUNCTION: apply smoothing to data from Tracking

function Tracking = smoothTracking_custom(Tracking, Params)
    % Smooth data using smooth() function
    % time = time stamps of position data
    % ux, uy = position data

    tic;
    
    smoothMethod = Params.Smoothing.method;
    smoothSpan = Params.Smoothing.span;
    part_names = Params.part_names;

    % Set up smoothing loop
    x_data = zeros(length(part_names), length(Tracking.Raw.(part_names{1})));
    y_data = zeros(size(x_data));
    smooth_x_data = zeros(size(x_data));
    smooth_y_data = zeros(size(x_data));

    for i = 1:length(part_names)
        x_data(i,:) = Tracking.Raw.(part_names{i})(1,:);
        y_data(i,:) = Tracking.Raw.(part_names{i})(2,:);
    end
    
    if Params.Smoothing.useGPU
        disp('Smoothing using parallel processing')
        parfor i = 1:length(part_names)
            ux = x_data(i,:)';
            uy = y_data(i,:)';
            x = smooth(ux, smoothSpan, smoothMethod);
            y = smooth(uy, smoothSpan, smoothMethod);
            smooth_x_data(i,:) = x';
            smooth_y_data(i,:) = y';
            
            % find NaNs that remain after smoothing and interpolate missing
            % data
            smooth_x_data(i,:) = fillmissing(smooth_x_data(i,:), 'spline');
            smooth_y_data(i,:) = fillmissing(smooth_y_data(i,:), 'spline');
        end
    else
        disp('Smoothing using CPU')
        for i = 1:length(part_names)
            ux = x_data(i,:)';
            uy = y_data(i,:)';
            x = smooth(ux, smoothSpan, smoothMethod);
            y = smooth(uy, smoothSpan, smoothMethod);
            smooth_x_data(i,:) = x';
            smooth_y_data(i,:) = y';
            
            % find NaNs that remain after smoothing and interpolate missing
            % data
            smooth_x_data(i,:) = fillmissing(smooth_x_data(i,:), 'spline');
            smooth_y_data(i,:) = fillmissing(smooth_y_data(i,:), 'spline');
        end
    end

    % Save to Tracking struct
    for i = 1:length(part_names)
        Tracking.Smooth.(part_names{i}) = [smooth_x_data(i,:); smooth_y_data(i,:)];
    end

    disp(['Data smoothed using ', smoothMethod, ' method and stored in Tracking.Smooth']);
    tm = toc;
    disp(['Smoothing completed in ' num2str(tm/60), ' minutes' ]);
end