% drawClassROIs
% C.G. 2/15/22
% Contact: cjgabrie@ucla.edu

% Find and allow users to draw ROIs that are pre-determined by individual
% classifiers (e.g. open field: arena bound and arena center)

function P = drawClassROIs(P, frame)

% Retrieve Params struct within P
params = P.Params;

% Search params (per behavior) for 'ROI' fields
beh_structs = fieldnames(params);

for i = 1:length(beh_structs)
    % Check for fields with 'ROI_Labels' (case insensitive)
    beh_fields = fieldnames(params.(beh_structs{i}));
    roi_check = contains(beh_fields, 'ROI_Labels', 'IgnoreCase', true);
    
    % Only one field with ROI allowed per classifier
    if sum(roi_check) == 1
        roi_match = beh_fields(roi_check);
        roi_labels = params.(beh_structs{i}).(roi_match{1});
        roi_limits = cell(size(roi_labels));
        
        for ii = 1:length(roi_labels)
            % Display frame image
            imshow(frame)
            
            % Plot other ROIs, if applicable
            if ii > 1
               hold on;
               for nroi = 1:(ii-1)
                   plot(polyshape(roi_limits{nroi}), 'FaceAlpha', 0.25)
               end
            end
            
            title(["Draw ROI limits" string(['(', beh_structs{i}, ': ' roi_labels{ii}, ')'])])
            
            % Draw new ROI
            temp = drawpolygon();
            roi_limits{ii} = temp.Position;
            close
        end
        
        % Save to P.Params
        P.Params.(beh_structs{i}).ROI_Limits = roi_limits;
    end
end
end