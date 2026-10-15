function [P, runSummary] = BehDEPOT_mainscript(P)

runSummary = struct();
runSummary.StartTime = datetime('now');
runSummary.Session = struct([]);

if ~isfield(P, 'noninteractive')
    P.noninteractive = false;
end

%% Collect files for single or batch session
if P.batchSession == 0
    P = getFiles_single(P);
elseif P.batchSession == 1
    % Collect 'video_folder_list' from 'P.video_directory'
    P.script_dir = pwd; % directory with script files (avoids requiring changes to path)
    has_file_manifest = isfield(P, 'video_file') && ~isempty(P.video_file) && ...
        isfield(P, 'tracking_file') && ~isempty(P.tracking_file);
    if (~isfield(P, 'video_directory') || isempty(P.video_directory)) && ~has_file_manifest
        if P.noninteractive
            error('BehaviorDEPOT:BehDEPOTMain:MissingVideoDirectory', ...
                'Batch noninteractive runs require P.video_directory or paired P.video_file/P.tracking_file lists.');
        end
        disp('Select directory containing other directories for analysis'); % point to folder for analysis
        if ~ispc
            menu('Select the directory containing folders for analysis', 'OK')
        end
        P.video_directory = uigetdir('','Select the directory containing folders for analysis'); %Directory with list of folders containing videos + tracking to analyze
    end
    if (~isfield(P, 'video_folder_list') || isempty(P.video_folder_list)) && ~has_file_manifest
        P.video_folder_list = prepBatch(string(P.video_directory)); %Generate list of videos to analyze
    end
    if ~isfield(P, 'part_save')
        P.part_save = [];
    end
    P.part_lookup = [];
    P.reuse_cue_names = [];
    if ~isfield(P, 'reuse_roi_names')
        P.reuse_roi_names = false;
    end
    if ~isfield(P, 'reuse_roi_limits')
        P.reuse_roi_limits = false;
    end
    
    % Collect files
    P = getFiles_batch(P);
end

%% RUN MAIN SCRIPT
for j = 1:numel(P.video_folder_list)
    
    %% RUN DATA PREP MODULE %%
    if P.dataPrep
        %% Data Prep Module
        [Params, Tracking, Metrics, P] = BD_dataPrep(P, j);

        %% Save Data
        if P.batchSession == 1
            analyzed_folder_name = getAnalyzedFolderName(P, j);
        else
            [video_path, vid_no_ext] = fileparts(P.video_file{j});
            analyzed_folder_name = fullfile(video_path, strcat(vid_no_ext, "_analyzed"));
        end
        
        saveDataPrep(analyzed_folder_name, Params, Tracking, Metrics);
        runSummary.Session(j).DataPrepFolder = char(analyzed_folder_name);
    end

    %% RUN BEHAVIOR ANALYSIS MODULE %%
    if P.beh_analysis

        %% Load data, if dataPrep Module is OFF
        if P.dataPrep == 0
            if P.batchSession == 1
                analyzed_folder_name = getAnalyzedFolderName(P, j);
            else
                [video_path, vid_no_ext] = fileparts(P.video_file{j});
                analyzed_folder_name = fullfile(video_path, strcat(vid_no_ext, "_analyzed"));
            end

            load(fullfile(analyzed_folder_name, 'Tracking.mat'))
            load(fullfile(analyzed_folder_name, 'Metrics.mat'))
            load(fullfile(analyzed_folder_name, 'Params.mat'))

            % Update params with new param values
            new_params = fieldnames(P.Params);
            for p = 1:length(new_params)
                Params.(new_params{p}) = P.Params.(new_params{p});
            end
        end

        %% Initialize Behavior Struct
        Behavior = struct();
        
        %% Apply Spatial Filter
        if Params.do_roi && Params.num_roi > 0
            [Params, Metrics, Behavior.Spatial] = calculateUserROI(Metrics, Params);
        else
            [Params, ~] = calculateUserROI(Metrics, Params);
        end
        
        %% Apply Temporal Filter
        if Params.do_events
            [Behavior.Temporal, Params, P] = calculateUserEvents(Params, P);
        end
        
        %% Run Behavior Classifiers
        classifier_list = P.classifierNames(P.classSelect);
        beh_names = P.behavior_names(P.classSelect);
        class_handles = cellfun(@str2func, classifier_list, 'UniformOutput', false);
        
        for i = 1:size(class_handles, 1)
            this_classifier = class_handles{i};
            Behavior.(beh_names{i}) = this_classifier(Params, Tracking, Metrics);
        end
        
        %% Save Behavior Data
        if P.batchSession == 1
            analyzed_folder_name = getAnalyzedFolderName(P, j);
        else
            [video_path, vid_no_ext] = fileparts(P.video_file{j});
            analyzed_folder_name = fullfile(video_path, strcat(vid_no_ext, "_analyzed"));
        end
        
        saveBehAnalysis(analyzed_folder_name, Params, Behavior);
        runSummary.Session(j).BehaviorFolder = char(analyzed_folder_name);
       
        %% Visualizations
        % Plot behavior bouts
        if size(fieldnames(Behavior), 1) > 0
            plotBouts(Behavior, analyzed_folder_name);
        end
        
        % Plot trajectory map
        if (Params.plotBeh) || (Params.plotSpace) || (Params.plotSpaceTime) % if plotting behavior, loop through behaviors and make individual figures
            frame_idx = fieldnames(Params.Frame);
            frame = Params.Frame.(frame_idx{randi(size(frame_idx,1))});
            plotTrajectoryMap(Metrics, frame, Params, Behavior, analyzed_folder_name);
        end
    end

    %% Prep for next session (if batch)
    if P.batchSession == 1
        % Reset for next batch
        clearvars -except j P runSummary;
        disp(['Analyzed: ' num2str(j) ' of ' num2str(numel(P.video_folder_list))])
        close;
    end
        
    disp('Analysis completed. Results stored in data folders.')
    close;
end

runSummary.EndTime = datetime('now');
end

function analyzed_folder_name = getAnalyzedFolderName(P, j)
if isfield(P, 'video_directory') && ~isempty(P.video_directory)
    analyzed_folder_name = fullfile(P.basedir, char(P.video_folder_list(j)), ...
        strcat(P.video_folder_list(j), '_analyzed'));
else
    [video_path, vid_no_ext] = fileparts(P.video_file{j});
    analyzed_folder_name = fullfile(video_path, strcat(vid_no_ext, "_analyzed"));
end
end
