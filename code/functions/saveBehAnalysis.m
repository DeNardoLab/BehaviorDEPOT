%saveBehAnalysis

%INPUT: analyzed_folder_name, Params, Tracking, Metrics, Behavior
%OUTPUT: saved MATLAB files for Params, Tracking, Metrics, Behavior
%structures
%FUNCTION: save structures as MATLAB files

function saveBehAnalysis(analyzed_folder_name, Params, Behavior)
    mkdir(analyzed_folder_name);
    cd(analyzed_folder_name)
    save('Params.mat', 'Params');
    
    if size(fieldnames(Behavior), 1) > 0
        save('Behavior.mat', 'Behavior');
    end

    close all
    cd('..')
end