function out = calculateROI(Behavior, Metrics, Params)
    if Params.num_roi > 0
        beh_name = fieldnames(Behavior);
        beh_cell = struct2cell(Behavior);
       
        loc = Metrics.Location;  
        all_roi = Params.roi;
        for r = 1:length(all_roi)  % loop through all ROIs
            roi_limits = all_roi{r};
            roi_name = Params.roi_name{r};
            
            in_roi = inpolygon(loc(1,:),loc(2,:),roi_limits(:,1),roi_limits(:,2));  % find frames when location is within ROI boundaries
            in_roi = in_roi';
            out.(roi_name).PerTimeInROI = sum(in_roi) / length(in_roi);
            out.(roi_name).inROIvector= in_roi';

             for i = 1:length(beh_cell)   % loop through behaviors
                i_beh_name = string(beh_name(i));  % load behvavior name
                i_beh_vec = Behavior.(i_beh_name).Vector;   % load behavior vector
                in_roi_beh = find(in_roi == 1 & i_beh_vec == 1);  % find frames when location is within ROI and behavior occurred
                roi_beh_vec = zeros(1,length(loc));
                roi_beh_vec(in_roi_beh) = 1;

                out_roi_beh = find(in_roi == 0 & i_beh_vec == 1);  % find frames when location is outside ROI and behavior occurred
                out_roi_beh_vec = zeros(1,length(loc));
                out_roi_beh_vec(out_roi_beh) = 1;

                out.(roi_name).(i_beh_name).inROIbehaviorVector = roi_beh_vec;  % vector of frames when behavior occurred within ROI
                out.(roi_name).(i_beh_name).PerBehaviorInROI = sum(roi_beh_vec) / sum(i_beh_vec);
             end
            roi_limits = [];

        end
    else
        out = [];
    end
end
