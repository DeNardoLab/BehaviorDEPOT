%saveBehAnalysis

%INPUT: analyzed_folder_name, Params, Tracking, Metrics, Behavior
%OUTPUT: saved MATLAB files for Params, Tracking, Metrics, Behavior
%structures
%FUNCTION: save structures as MATLAB files

function saveBehAnalysis(analyzed_folder_name, Params, Behavior)
    if ~isfolder(analyzed_folder_name)
        mkdir(analyzed_folder_name);
    end
    save(fullfile(analyzed_folder_name, 'Params.mat'), 'Params');
    
    if size(fieldnames(Behavior), 1) > 0
        save(fullfile(analyzed_folder_name, 'Behavior.mat'), 'Behavior');
    end
end
