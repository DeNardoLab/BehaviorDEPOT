        
function roi_struct = searchROI(all_roi, roi_names, loc)

for i = 1:length(all_roi)  % loop through all ROIs
    roi_limits = all_roi{i};
    roi_name = roi_names{i};

    in_roi = inpolygon(loc(1,:), loc(2,:), roi_limits(:,1), roi_limits(:,2));  % find frames when location is within ROI boundaries
    roi_struct.(roi_name).PerTimeInROI = sum(in_roi) / length(in_roi);
    roi_struct.(roi_name).inROIvector = in_roi;
    roi_struct.(roi_name).Bouts = findStartStop(roi_struct.(roi_name).inROIvector);
end

end