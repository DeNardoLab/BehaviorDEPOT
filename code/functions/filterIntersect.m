% Go through spatial and temporal filters to find when both spatial and
% temporal filters are true. Iterate across all behaviors

function out = filterIntersect(Behavior, Params)
            
    
    % gather behaviors 
    beh_name = fieldnames(Behavior);
    event_names = fieldnames(Behavior.Temporal);
    roi_names = fieldnames(Behavior.Spatial);
    beh_cell = struct2cell(Behavior);
    
    for i = 1:length(beh_cell)   % loop through behaviors
        i_beh_name = string(beh_name(i));  % load behavior name

        for j = 1:Params.num_roi % loop through ROIs
            
            roi_vec = Behavior.Spatial.(roi_names{j}).inROIvector;        
            roi_beh_vec = Behavior.Spatial.(roi_names{j}).(i_beh_name).inROIbehaviorVector;

            for k = 1:Params.num_events  % loop through events
                event_beh_vec = Behavior_Filter.Temporal.(event_names{k}).(i_beh_name).BehInEventVector';   % find when ROI, event, and behavior == true
                out_name = [beh_name{i} '_' roi_names{j} '_' event_names{k}];
                out_name_vec = [out_name '_Vector'];
                
                intersect_true = find(event_beh_vec == 1 & roi_beh_vec == 1);
                out_vec = zeros(size(roi_beh_vec));
                out_vec(intersect_true) = 1;
                out.SpaTemBeh.(out_name_vec) = out_vec;
                
                event_bouts = Behavior_Filter.Temporal.(event_names{k}).EventBouts;
                
                out_name_cue = [out_name '_CueVectors'];
                out.SpaTemBeh.(out_name_cue) = [];
                for m = 1:size(event_bouts,1)  % loop through each cue    
                    m_name = [event_names{k} '_' roi_names{j}];
                    m_roi_vec = roi_vec(event_bouts(m,1):event_bouts(m,2));
                    out.ROIduringCue_PerTime.(m_name){m} = sum(m_roi_vec) / length(m_roi_vec);
                    if m == 1
                        out.ROIduringCue_Vector.(m_name) = m_roi_vec;
                    else
                        out.ROIduringCue_Vector.(m_name) = [out.ROIduringCue_Vector.(m_name); m_roi_vec];
                    end
                    
                    
                    this_behcue = out_vec(event_bouts(m,1):event_bouts(m,2));
                    out.SpaTemBeh.(out_name_cue) = [out.SpaTemBeh.(out_name_cue); this_behcue];
                end

            end
            
            
        end
    end
end