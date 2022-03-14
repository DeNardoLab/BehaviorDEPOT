% P_calculateExploration
% ZZ 2022.03.07

function Params = P_calculateExploration()
    
    % minDuration (sec) of behavior bout
    Params.Exploration.minDuration = 0.25;
    
    % distance (cm) of region around object to include
    Params.Exploration.objDistThresh = 2;
    
    % distance (cm) of nose within original object ROI to exclude (ie
    % climbing)
    Params.Exploration.noseDist = 2;
    
end