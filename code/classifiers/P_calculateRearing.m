% P_calculateRearing

% PARAMS:
% 1) minDuration (sec)
% 2) ROI_Labels:
    % Arena_Floor
    
function Params = P_calculateRearing()

    Params.Rearing.minDuration = 0.5; % Set min duration of behavior bout
    Params.Rearing.ROI_Labels = {'Arena_Floor'};

end