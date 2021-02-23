%saveAnalysis

%INPUT: analyzed_folder_name, Params, Tracking, Metrics, Behavior
%OUTPUT: saved MATLAB files for Params, Tracking, Metrics, Behavior
%structures
%FUNCTION: save structures as MATLAB files

function saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior, Behavior_Filter)

    mkdir([analyzed_folder_name]);
    cd(analyzed_folder_name)
    save('Tracking.mat', 'Tracking');
    save('Behavior.mat', 'Behavior');
    save('Metrics.mat', 'Metrics');
    save('Params.mat', 'Params');
    save('Behavior_Filter.mat', 'Behavior_Filter');
    %savefig(Plots.pointValidation, 'Point Validation');
    %savefig(Plots.bouts, 'Behavior Bouts');
    %savefig(Plots.behavior, 'Behavior Map');
    close all
end