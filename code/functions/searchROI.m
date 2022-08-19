%% searchROI - grab info from drawn ROIs and save to roi_struct (& Metrics for 4-point ROIs)

function [roi_struct, Metrics] = searchROI(all_roi, roi_names, loc, Params, Metrics)

for i = 1:length(all_roi)  % loop through all ROIs
    roi_limits = all_roi{i};
    roi_name = roi_names{i};

    in_roi = inpolygon(loc(1,:), loc(2,:), roi_limits(:,1), roi_limits(:,2));  % find frames when location is within ROI boundaries
    
    if size(roi_limits, 1) == 4
        % Grab video frame info from Params.Video
        x_max = Params.Video.frameWidth;
        y_max = Params.Video.frameHeight;

        C.TL_corner = [0, 0];
        C.BL_corner = [0, y_max];
        C.TR_corner = [x_max, 0];
        C.BR_corner = [x_max, y_max];
        
        corners = fieldnames(C);

        for c = 1:length(corners)   
            this_corner = C.(corners{c}); 
            dist_to_corner = sqrt(sum((roi_limits - this_corner).^2, 2));
            [~, ind] = min(dist_to_corner);

            % Save organized ROI corners to R
            R.(corners{c}) = roi_limits(ind, :);
        end

        % Calculate edge coordinates
        R.T_edge = mean([R.TL_corner; R.TR_corner], 1);
        R.B_edge = mean([R.BL_corner; R.BR_corner], 1);
        R.L_edge = mean([R.TL_corner; R.BL_corner], 1);
        R.R_edge = mean([R.TR_corner; R.BR_corner], 1);

        % Find center pt coords (of quadrilateral)
        % Calculate centroids of triangles drawn via diagonals
        c1 = mean([R.TL_corner; R.BL_corner; R.TR_corner], 1);
        c2 = mean([R.TL_corner; R.BR_corner; R.TR_corner], 1);
        c3 = mean([R.BL_corner; R.BR_corner; R.TR_corner], 1);
        c4 = mean([R.BL_corner; R.BR_corner; R.TL_corner], 1);

        R.center = mean([c1; c2; c3; c4], 1);

        dist_pts = fieldnames(R);

        % Calculate distance from edges and corners
        for c = 1:length(dist_pts)

            this_pt = R.(dist_pts{c});

            % Find difference between xy location and xy coords of this_pt
            dist_to_pt = [loc(1,:) - this_pt(1); loc(2,:) - this_pt(2)];
        
            % Pythagorean theorem; save to Metrics.Dist
            out_dist = sqrt(dist_to_pt(1,:).^2 + dist_to_pt(2,:).^2);
            Metrics.Dist.([roi_name, '_', dist_pts{c}]) = out_dist;
            roi_struct.(roi_name).Dist.(dist_pts{c}) = out_dist;

            clearvars dist_to_pt out_dist
        end
        clearvars dist_pts
  
    else % Non-quadrilateral ROIs: calculate dist from each vertex, dist from center of shape, and save to appropriate structs 
        dist_to_origin = sqrt(sum((roi_limits - [0,0]).^2, 2));
        [~, ind] = min(dist_to_origin);
        if ind > 1
            new_order = [ind:size(roi_limits, 1), 1:ind-1];
        else
            new_order = 1:size(roi_limits, 1);
        end
        
        % Rearrange the ROI pts starting from pt closest to origin
        roi_limits = roi_limits(new_order,:);

        % Find centroid of ROI
        plgn = polyshape(roi_limits);
        [c_x, c_y] = centroid(plgn);
        
        % Save pts to calculate distance from
        dist_pts = [roi_limits; c_x, c_y];

        % Generate labels for vertices and center
        labels = cell(size(dist_pts, 1), 1);
        for n = 1:size(dist_pts, 1)
            if n == size(dist_pts, 1)
                labels{n} = 'Center';
            else
                labels{n} = ['Vertex', num2str(n)];
            end
        end

        for c = 1:size(dist_pts, 1)
            this_pt = dist_pts(c,:);

            % Find difference between xy location and xy coords of this_pt
            dist_to_pt = [loc(1,:) - this_pt(1); loc(2,:) - this_pt(2)];
        
            % Pythagorean theorem; save to Metrics.Dist
            out_dist = sqrt(dist_to_pt(1,:).^2 + dist_to_pt(2,:).^2);
            Metrics.Dist.([roi_name, '_', labels{c}]) = out_dist;
            roi_struct.(roi_name).Dist.(labels{c}) = out_dist;

            clearvars dist_to_pt out_dist
        end
        clearvars dist_pts
    end
    
    roi_struct.(roi_name).ROI = roi_limits;
    roi_struct.(roi_name).PerTimeInROI = sum(in_roi) / length(in_roi);
    roi_struct.(roi_name).inROIvector = in_roi;
    roi_struct.(roi_name).Bouts = findStartStop(roi_struct.(roi_name).inROIvector);
end
end