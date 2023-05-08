%genTracking

%INPUT: data (variable containing data read from CSV/H5), hmpl,
%& cutoffThreshold

%OUTPUT: Tracking structure

%FUNCTION: Convert data into Tracking structure format; apply hampel
%correction; remove unlikely points from Tracking

function Tracking = genTracking_custom(data, Params)
    
    cutoffThreshold = Params.cutoffThreshold;
    hmpl = Params.hampel;
    hmpl_span = Params.hampel_span;
    part_names = Params.part_names;
    
    % Convert data to Tracking structure and apply hampel correction
   
    for i = 1:length(part_names)
        this_part = part_names{i};
        Tracking.Raw.(this_part) = data(3*i-2: 3*i ,:);
        if hmpl
            Tracking.Raw.(this_part) = hampel(Tracking.Raw.(this_part)', hmpl_span)';
        end
        
        if ~contains(Params.tracking_type, 'sleap')
            % toss data below likelihood threshold
            Tracking.Raw.NaNs.(this_part) = find(Tracking.Raw.(this_part)(3,:) <= cutoffThreshold);
            Tracking.Raw.(this_part)(1:2, Tracking.Raw.NaNs.(this_part)) = NaN;
            i_reject = ['Percent_Rejcted_' this_part];
            Tracking.Raw.NaNs.(i_reject) = length(Tracking.Raw.NaNs.(this_part))/Params.Video.totalFrames*100;
        end
    end
    disp('Tracking Structure Assembled')
    if hmpl
        disp('Hampel Correction Applied')
    end

end