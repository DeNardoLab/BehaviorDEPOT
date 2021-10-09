%saveAnalysis

%INPUT: analyzed_folder_name, Params, Tracking, Metrics, Behavior
%OUTPUT: saved MATLAB files for Params, Tracking, Metrics, Behavior
%structures
%FUNCTION: save structures as MATLAB files

function saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior, Behavior_Filter)
    filter_check = struct;
    mkdir([analyzed_folder_name]);
    cd(analyzed_folder_name)
    save('Tracking.mat', 'Tracking');
    save('Behavior.mat', 'Behavior');
    save('Metrics.mat', 'Metrics');
    save('Params.mat', 'Params');
    if ~isequal(Behavior_Filter, struct)
        save('Behavior_Filter.mat', 'Behavior_Filter');
    end
    %savefig(Plots.pointValidation, 'Point Validation');
    %savefig(Plots.bouts, 'Behavior Bouts');
    %savefig(Plots.behavior, 'Behavior Map');
    close all
end