%saveAnalysis

%INPUT: analyzed_folder_name, Params, Tracking, Metrics, Behavior
%OUTPUT: saved MATLAB files for Params, Tracking, Metrics, Behavior
%structures
%FUNCTION: save structures as MATLAB files

function saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior)
    mkdir(analyzed_folder_name);
    cd(analyzed_folder_name)
    save('Tracking.mat', 'Tracking');
    save('Metrics.mat', 'Metrics');
    save('Params.mat', 'Params');
    
    if size(fieldnames(Behavior), 1) > 0
        save('Behavior.mat', 'Behavior');
    end

    close all
end