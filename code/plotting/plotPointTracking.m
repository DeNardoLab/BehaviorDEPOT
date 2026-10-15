%plotPointTracking

function pointValidation = plotPointTracking(Tracking, Params, frame, frame_idx, targetAxes)
    % visual verification of point tracking and body part indexing
    if nargin < 5 || isempty(targetAxes)
        pointValidation = figure('Name', ...
            'Example point alignment and body part indexing');
        targetAxes = axes(pointValidation);
    else
        pointValidation = targetAxes;
    end

    frame_number = regexp(char(frame_idx), '\d+$', 'match', 'once');
    frame_idx = str2double(frame_number);
    if isnan(frame_idx)
        error('BehaviorDEPOT:plotPointTracking:InvalidFrameIndex', ...
            'The selected preview frame name must end in a frame number.');
    end

    part_names = Params.part_names;
    legendLabels = cell(size(part_names));
    markerHandles = gobjects(1, numel(part_names));
    imshow(frame, 'Parent', targetAxes);
    hold(targetAxes, 'on');
    
    for i = 1:length(part_names)
        this_part = Tracking.Smooth.(part_names{i});
        markerHandles(i) = plot(targetAxes, this_part(1,frame_idx), ...
            this_part(2,frame_idx), 'o', 'MarkerSize', 5, 'LineWidth', 2);
        legendLabels{i} = strrep(part_names{i}, '_', ' ');
    end
    legend(targetAxes, markerHandles, legendLabels, 'Interpreter', 'none', ...
        'Location', 'bestoutside');
    axis(targetAxes, 'image');
    axis(targetAxes, 'off');
end

