function BehDEPOT_mainscript(P)

%% Initialize single session, if applicable
if P.batchSession == 0
    P.script_dir = pwd; % directory with script files (avoids requiring changes to path)
    disp('Select tracking file'); % point to folder for analysis
    if ~ispc
        menu('Select tracking file', 'OK')
    end
    [ft pt] = uigetfile('*.*','Select tracking file');
    cd(pt)
    disp('Select video file'); % point to folder for analysis
    if ~ispc
        menu('Select video file', 'OK')
    end
    [fv pv] = uigetfile('*.*','Select video file');
    basedir = pt;
    P.tracking_file = [pt ft];
    P.video_file = [pv fv];
    P.video_folder_list = P.video_file;
    [frame, frame1, frame_idx, P] = videoInterface([pv fv], P);

elseif P.batchSession == 1
%% Initialize batch session
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
end

%% Run main script
for j = 1:size(P.video_folder_list, 2)
    % Initialize batch session specific parameters
    if P.batchSession == 1
        % Initialize 
        current_video = P.video_folder_list(j);
        
        if ispc
            video_folder = strcat(P.video_directory, '\', current_video);
        else
            video_folder = strcat(P.video_directory, '/', current_video);
        end
        
        cd(video_folder) %Folder with data files
        basedir = pwd; %Assign current folder to basedir

        if size(dir('*.avi'), 1) == 1
            vid_extension = '*.avi';
        elseif size(dir('*.mp4'), 1) == 1
            vid_extension = '*.mp4';
        else
            disp('ERROR: Video Not Recognized. Ensure a single video file (avi/mp4) is in each session folder in the batch directory')
            return
        end
        
        %Collect video name from vid_extension
        V = dir(vid_extension);
        try
            video_name = V.name;
        catch ME
            if (strcmp(ME.identifier,'MATLAB:needMoreRhsOutputs'))
                msg = ['Error loading video']; % common error is to not have correct video file type selected
                causeException = MException('MATLAB:needMoreRhsOutputs',msg);
                ME = addCause(ME,causeException);
            end
            rethrow(ME)
        end

        clear V

        % back to script dir
        cd(P.script_dir)
    
        % Collect frames for plots and draw ROIs
        if ispc
            full_vid_path = strcat(video_folder,'\',video_name);
        else
            full_vid_path = strcat(video_folder,'/',video_name);
        end
        
        [frame, frame1, frame_idx, P] = videoInterface(full_vid_path, P);
    end
    %% Save parameters to Params structure
    Params = makeParamsStruct(P);    
    Params.basedir = basedir;
    
    if P.batchSession == 0
        Params.tracking_file = P.tracking_file;
        Params.video_file = P.video_file;
    end
    
    %% CSV/H5 Registration
    [data, Params] = importDLCTracking(Params);
    Params.numFrames = size(data, 2);
     
    %% Convert data to Tracking structure and apply hampel correction
    cd(P.script_dir);
    Tracking = genTracking_custom(data, Params);
    disp(['Tracked ' num2str(length(Params.part_names)) ' points']);

    %% Smooth Tracking Data
    Tracking = smoothTracking_custom(Tracking, Params);
    
    %% Visual verification of point tracking and body part indexing
    Plots.pointValidation = plotPointTracking(Tracking, Params, frame, frame_idx);
    
    %% METRIC CALCULATION
    [Metrics, Tracking, Params, P] = calculateMetrics(Tracking, Params, P);
 
    %% RUN BEHAVIOR CLASSIFIERS 
    classifier_list = P.classifierNames(P.classSelect);
    beh_names = P.behavior_names(P.classSelect);
    class_handles = cellfun(@str2func, classifier_list, 'UniformOutput', false);
    Behavior = struct();
    
    for i = 1:size(class_handles, 1)
        this_classifier = class_handles{i};
        Behavior.(beh_names{i}) = this_classifier(Params, Tracking, Metrics);
    end
    
    % Initialize Behavior_Filter
    Behavior_Filter = struct;  % separate struct to hold filtered behavior
    
    %% APPLY SPATIAL FILTER(S)
    % separate behavior within and outside ROI
    if Params.do_roi && Params.num_roi > 0
        Behavior_Filter.Spatial = calculateROI(Behavior, Metrics, Params);
    end
    
    %% APPLY TEMPORAL FILTER
    % seperate behavior during time-locked events
    if Params.do_events
        [Behavior_Filter.Temporal, Params, P] = calculateEvents(Behavior, Params, P);
    end
    
   %% INTERSECT SPATIAL AND TEMPORAL FILTERS
    if Params.do_roi && Params.do_events
        Behavior_Filter.Intersect = filterIntersect(Behavior, Behavior_Filter, Params);
    end
        
    %% Save Data
    if P.batchSession == 1
        if ispc
            analyzed_folder_name = strcat(basedir, '\', current_video, '_analyzed');
        else
            analyzed_folder_name = strcat(basedir, '/', current_video, '_analyzed');
        end
    else
        analyzed_folder_name = string([P.video_file,'_analyzed']);
    end
    
    if exist('Behavior_Filter')
        saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior, Behavior_Filter);
    else
        saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior);
    end
   
    %% VISUALIZATIONS
    % Plot Behavior Bouts
    if size(fieldnames(Behavior), 1) > 0
    plotBouts(Behavior, analyzed_folder_name);
    
    % plot trajectory map
    plotTrajectoryMap(Metrics, frame1, Params, Behavior, analyzed_folder_name);
    
    % Prep for next session (if batch)
        if P.batchSession == 1
            % reset for next batch
            clearvars -except j P;
            disp(['Analyzed ' num2str(j) ' of ' num2str(length(P.video_folder_list))])
            close;
        end
    end
    disp('Analysis completed. Results stored in data folders.')
    close;
end