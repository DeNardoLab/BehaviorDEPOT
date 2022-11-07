% P_calculateEPM

%PARAMS:

% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) ROI_Labels
    % a) Open Arm 1 ROI (O1)
    % b) Open Arm 2 ROI (O2)
    % c) Closed Arm 1 ROI (C1)
    % d) Closed Arm 2 ROI (C2)
    % e) Center ROI (Center)

function Params = P_calculateEPM()

    Params.EPM.windowWidth = 10; 
    Params.EPM.countThreshold = 6; 
    Params.EPM.ROI_Labels = {'O1','O2','C1','C2','Center'};

end