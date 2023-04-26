function BehDEPOT_mainscript(P)

%% Collect files for single or batch session
if P.batchSession == 0
    P = getFiles_single(P);
elseif P.batchSession == 1
    % Collect 'video_folder_list' from 'P.video_directory'
    P.script_dir = pwd; % directory with script files (avoids requiring changes to path)
    disp('Select directory containing other directories for analysis'); % point to folder for analysis
    if ~ispc
        menu('Select the directory containing folders for analysis', 'OK')
    end
    P.video_directory = uigetdir('','Select the directory containing folders for analysis'); %Directory with list of folders containing videos + tracking to analyze
    P.video_folder_list = prepBatch(string(P.video_directory)); %Generate list of videos to analyze
    P.part_save = [];
    P.part_lookup = [];
    P.reuse_cue_name = [];
    
    % Collect files
    P = getFiles_batch(P);
end

%% RUN MAIN SCRIPT
for j = 1:size(P.video_folder_list, 2)
    
    %% RUN DATA PREP MODULE %%
    if P.dataPrep
        %% Data Prep Module
        [Params, Tracking, Metrics, P] = BD_dataPrep(P, j);

        %% Save Data
        if P.batchSession == 1
            analyzed_folder_name = strcat(P.basedir, addSlash(), P.video_folder_list(j), addSlash(), P.video_folder_list(j), '_analyzed');
        else
            analyzed_folder_name = strcat(P.video_file,"_analyzed");
        end
        
        saveDataPrep(analyzed_folder_name, Params, Tracking, Metrics);
    end

    %% RUN BEHAVIOR ANALYSIS MODULE %%
    if P.beh_analysis

        %% Load data, if dataPrep Module is OFF
        if P.dataPrep == 0
            startDir = pwd;

            if P.batchSession == 1
                analyzed_folder_name = strcat(P.basedir, addSlash(), P.video_folder_list(j), addSlash(), P.video_folder_list(j), '_analyzed');
            else
                analyzed_folder_name = strcat(P.video_file,"_analyzed");
            end

            cd(analyzed_folder_name)
            load('Tracking.mat')
            load('Metrics.mat')
            load('Params.mat')

            % Update params with new param values
            new_params = fieldnames(P.Params);
            for p = 1:length(new_params)
                Params.(new_params{p}) = P.Params.(new_params{p});
            end

            cd(startDir)   
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
        
    %  %% Intersect Spatial & Temporal Filters
    %     if Params.do_roi && Params.do_events
    %         Behavior.Intersect = filterIntersect(Behavior, Params);
    %     end
            
        %% Save Behavior Data
        if P.batchSession == 1
            analyzed_folder_name = strcat(P.basedir, addSlash(), P.video_folder_list(j), addSlash(), P.video_folder_list(j), '_analyzed');
        else
            analyzed_folder_name = strcat(P.video_file,"_analyzed");
        end
        
        saveBehAnalysis(analyzed_folder_name, Params, Behavior);
       
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
        clearvars -except j P;
        disp(['Analyzed: ' num2str(j) ' of ' num2str(length(P.video_folder_list))])
        close;
    end
        
    disp('Analysis completed. Results stored in data folders.')
    close;
end
end