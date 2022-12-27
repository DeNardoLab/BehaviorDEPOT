%saveAnalysis

%INPUT: analyzed_folder_name, Params, Tracking, Metrics, Behavior
%OUTPUT: saved MATLAB files for Params, Tracking, Metrics, Behavior
%structures
%FUNCTION: save structures as MATLAB files

function saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics)
    mkdir(analyzed_folder_name);
    cd(analyzed_folder_name)
    save('Tracking.mat', 'Tracking');
    save('Metrics.mat', 'Metrics');
    save('Params.mat', 'Params');

    close all
    cd('..')
end