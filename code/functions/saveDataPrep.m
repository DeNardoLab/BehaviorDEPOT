%saveDataPrep

%INPUT: analyzed_folder_name, Params, Tracking, Metrics
%OUTPUT: saved MATLAB files for Params, Tracking, and Metrics
%structures
%FUNCTION: save structures as MATLAB files

function saveDataPrep(analyzed_folder_name, Params, Tracking, Metrics)
    mkdir(analyzed_folder_name);
    save(fullfile(analyzed_folder_name, 'Tracking.mat'), 'Tracking');
    save(fullfile(analyzed_folder_name, 'Metrics.mat'), 'Metrics');
    save(fullfile(analyzed_folder_name, 'Params.mat'), 'Params');
end
