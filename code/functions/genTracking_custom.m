%genTracking

%INPUT: data (variable containing data read from CSV/H5), hmpl,
%& cutoffThreshold

%OUTPUT: Tracking structure

%FUNCTION: Convert data into Tracking structure format; apply hampel
%correction; remove unlikely points from Tracking

function Tracking = genTracking_custom(data, Params)
    
    cutoffThreshold = Params.cutoffThreshold;
    hmpl = Params.hampel;
    % Convert data to Tracking structure and apply hampel correction
    part_names = Params.part_names;
    for i = 1:length(part_names)
        this_part = part_names{i};
        Tracking.Raw.(this_part) = data(i*3-1:i*3+1,:);
        if hmpl
            Tracking.Raw.(this_part) = hampel(Tracking.Raw.(this_part));
        end
        
        % toss data below likelihood threshold
        Tracking.Raw.NaNs.(this_part) = find(Tracking.Raw.(this_part)(3,:) <= cutoffThreshold);
        Tracking.Raw.(this_part)(1:2, Tracking.Raw.NaNs.(this_part)) = NaN;

        i_reject = ['Percent_Rejcted_' this_part];
        Tracking.Raw.NaNs.(i_reject) = length(Tracking.Raw.NaNs.(this_part))/Params.Video.totalFrames*100;
    end
    disp('Tracking Structure Assembled')
    if hmpl
        disp('Hampel Correction Applied')
    end

end