%plotPointTracking

function pointValidation = plotPointTracking(Tracking, Params, frame, frame_idx)
    % visual verification of point tracking and body part indexing
    frame_idx = str2num(frame_idx(2:end));

    part_names = Params.part_names;
    leg = {};
    figure('Name','Example point alignment and body part indexing');
    imshow(frame);
    hold on;
    
    for i = 1:length(part_names)
        i_part = string(part_names{i});
        this_part = Tracking.Smooth.(i_part);
        plot(this_part(1,frame_idx), this_part(2,frame_idx), 'o', 'MarkerSize', 5, 'LineWidth', 2);
        leg{i} = i_part;
    end
    legend(string(leg));
    pointValidation = gcf;
end

