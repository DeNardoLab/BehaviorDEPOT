% P_calculateOFT

%PARAMS:

% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) ROI_Labels:
    % a) Arena (ROI of full arena)
    % b) Center (center of arena)

function Params = P_calculateOFT()

    Params.OFT.windowWidth = 10; 
    Params.OFT.countThreshold = 6; 
    Params.OFT.ROI_Labels = {'Arena', 'Center'};

end