% P_calculatePMA

%PARAMS:

% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) cue_name: name of the cue present in the CSV file
% 4) ROI_Labels
    % a) Platform

function Params = P_calculatePMA()

    Params.PMA.windowWidth = 10; 
    Params.PMA.countThreshold = 6;
    Params.PMA.cue_name = 'Tone';
    Params.PMA.ROI_Labels = {'Platform'};
    

end