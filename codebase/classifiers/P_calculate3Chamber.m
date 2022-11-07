% P_calculateThreeChamber

%PARAMS:
% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) ROI_Labels:
    % a) Chamber1
    % b) Chamber2
    % c) Chamber3

function Params = P_calculateThreeChamber()

    Params.ThreeChamber.windowWidth = 10; 
    Params.ThreeChamber.countThreshold = 6; 
    Params.ThreeChamber.ROI_Labels = {'Chamber1', 'Chamber2', 'Chamber3'};

end