% P_calculateTMaze

%PARAMS:
% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) ROI_Labels:
    % a) Approach
    % b) Choice
    % c) Effort_L
    % d) Effort_R
    % e) Reward_L
    % f) Reward_R

function Params = P_calculateTMaze()

    Params.TMaze.windowWidth = 10; 
    Params.TMaze.countThreshold = 6; 
    Params.TMaze.ROI_Labels = {'Approach', 'Choice', 'Effort_L', 'Effort_R', 'Reward_L', 'Reward_R'};

end