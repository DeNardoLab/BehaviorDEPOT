% calculateUserROI()
% C.G. 1/28/22
% Contact: cjgabrie@ucla.edu

function [Params, ROIstruct] = calculateUserROI(Metrics, Params)

ROIstruct = struct();

loc = Metrics.Location; % Set location

if Params.do_roi && Params.num_roi > 0
    all_roi = Params.roi; % Set all ROIs
    roi_names = Params.roi_name; % Set all ROI names
    ROIstruct = searchROI(all_roi, roi_names, loc);
end

clearvars all_roi roi_names
% Add functionality to check and calculate classifier-based ROIs
% Check Params for structs (potential Behaviors)

param_fields = fieldnames(Params);
struct_check = zeros(size(param_fields));

for i = 1:length(param_fields)
    is_struct = isstruct(Params.(param_fields{i}));
    struct_check(i) = is_struct;
end

struct_inds = find(struct_check)';

for i = struct_inds
    tmp_struct = Params.(param_fields{i});
    tmp_fields = fieldnames(tmp_struct);
    limits_search = contains(tmp_fields, 'ROI_Limits');
    labels_search = contains(tmp_fields, 'ROI_Labels', 'IgnoreCase', true);
    if sum(limits_search) + sum(labels_search) == 2
        all_roi = tmp_struct.(tmp_fields{limits_search}); % Set all ROIs
        roi_names = tmp_struct.(tmp_fields{labels_search}); % Set all ROI names
        classROIstruct = searchROI(all_roi, roi_names, loc);
        for ii = 1:length(roi_names)
            Params.(param_fields{i}).(roi_names{ii}) = classROIstruct.(roi_names{ii});
        end
    end
end
end