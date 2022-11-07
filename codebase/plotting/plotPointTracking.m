%plotPointTracking

%INPUT: Tracking, Params, frame, frame index
%OUTPUT: Behavior.Freezing structure

%FUNCTION: calculate the freezing frames via transformation of data from
%the Metrics structure and save into Behavior structure

% Future: Calculate average velocity of body; test in place of
% RearBackVelocity

function pointValidation = plotPointTracking(Tracking, Params, frame, frame_idx)
    % visual verification of point tracking and body part indexing
    part_names = Params.part_names;
    leg = {};
    figure('Name','Example point alignment and body part indexing');
    imshow(frame);
    hold on;
    
    for i = 1:length(part_names)
        i_part = string(part_names{i});
        plot(Tracking.Smooth.(i_part)(1,frame_idx), Tracking.Smooth.(i_part)(2,frame_idx),'o', 'MarkerSize', 5, 'LineWidth', 2);
        leg{i} = i_part;
    end
    legend(string(leg));
    pointValidation = gcf;
end

