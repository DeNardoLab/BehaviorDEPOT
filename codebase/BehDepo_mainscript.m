function BehDepo_mainscript(P)
%% Additional parameters

%Adjustable Parameters
P.hmpl = 1; %Apply hampel transformation to DLC data (outlier correction); 1 = On
P.cutoffThreshold = 0.1; % Minimum confidence value for retaining DLC-tracked points based on DLC p-value; throws out values from 0 to chosen threshold

%Smoothing Parameters
%% %%%%%%%%-UPDATE TO SET IN GUI-%%%%%%%%%%
P.smoothMethod = 'lowess';
P.smoothSpan = 14;

%% %%%%%%%%----------------------%%%%%%%%%%

% Behavior Classification Parameters
% Freezing Parameters
% P.freezing_minDuration = 0.90; % (seconds) set minimum duration of freezing events to include
% P.freezing_velocityThreshold = 0.38; % (pixels per frame) set velocity maximum for freezing
% P.freezing_angleThreshold = 0.27; % (degrees) set angular movement max for freezing
P.freezing_windowWidth = P.freezing_minDuration * 0.7111; % empirically-determined
P.freezing_countThreshold = 0.2; % empirically-determined

%% Batch Setup
% Collect 'video_folder_list' from 'P.video_directory'
P.script_dir = pwd; % directory with script files (avoids requiring changes to path)
disp('Select directory containing other directories for analysis'); % point to folder for analysis
P.video_directory = uigetdir('','Select the directory containing folders for analysis'); %Directory with list of folders containing videos + tracking to analyze
P.video_folder_list = prepBatch(string(P.video_directory)); %Generate list of videos to analyze
P.part_save = [];
P.part_lookup = [];
P.reuse_cue_name = [];

for j = 1:length(P.video_folder_list)
    % Initialize 
    current_video = P.video_folder_list(j);    
    video_folder = strcat(P.video_directory, '\', current_video);
    cd(video_folder) %Folder with data files
    basedir = pwd; %Assign current folder to basedir
    

    if size(dir('*.avi'), 1) == 1
        vid_extension = '*.avi';
    elseif strcmpi(P.video_type, 'mp4')
        vid_extension = '*.mp4';
    else
        disp('Video Not Recognized. Check P.video_type variable')
        return
    end
    V = dir(vid_extension);
    try
        video_name = V.name;
    catch ME
        if (strcmp(ME.identifier,'MATLAB:needMoreRhsOutputs'))
            msg = ['Error loading video. Double check P.video_type matches actual video filetype']; % common error is to not have correct video file type selected
            causeException = MException('MATLAB:needMoreRhsOutputs',msg);
            ME = addCause(ME,causeException);
        end
        rethrow(ME)
    end
    
    clear V

    % back to script dir
    cd(P.script_dir)
    
    %% Collect frames for plots and draw ROIs
    [frame, frame1, frame_idx, P] = videoInterface(strcat(video_folder,'\',video_name), P);
    
    %% Save parameters to Params structure
    Params = makeParamsStruct(P);    
    Params.basedir = basedir;    
    %% CSV/H5 Registration
    [data, Params] = importDLCTracking(Params);
     
    %% Convert data to Tracking structure and apply hampel correction
    cd(P.script_dir);   
    Tracking = genTracking_custom(data, Params);
    disp(['Tracked ' num2str(length(Params.part_names)) ' points']);

    %% Smooth Tracking Data
    Tracking = smoothTracking_custom(Tracking, Params);
    
    % visual verification of point tracking and body part indexing
    Plots.pointValidation = plotPointTracking(Tracking, Params, frame, frame_idx);
   
    
    %% METRIC CALCULATION
    [Metrics, Tracking, Params, P] = calculateMetrics_custom(Tracking, Params, P);
 
    %% BEHAVIOR CLASSIFIERS
    % FREEZING
    if Params.do_freezing_classifier
        Behavior.Freezing = calculateFreezing_custom(Metrics, Params);
    end

    % WALL REARING
    if Params.do_wallrearing_classifier
        Behavior.WallRearing = calculateRearing(Tracking, Params);
    end
    
    % MOVING CLASSIFIER
   if Params.do_moving_classifier
        Behavior.Moving = calculateMoving(Metrics, Params);
    end
    
    %% APPLY FILTERS TO BEHAVIORS
    Behavior_Filter = struct;  % separate struct to hold filtered behavior
    %% APPLY SPATIAL FILTER
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
        
    %% Save 
    analyzed_folder_name = strcat(basedir, '\', current_video, '_analyzed');
    saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior, Behavior_Filter) 
   
    %% VISUALIZATIONS
    % plot freezing bouts
    plot_bouts(Behavior, analyzed_folder_name);
    
    % plot trajectory map
    plotTrajectoryMap(Metrics, frame1, Params, Behavior, analyzed_folder_name);
    
    % reset for next batch
    clearvars -except j P;
    disp(['Analyzed ' num2str(j) ' of ' num2str(length(P.video_folder_list))])
    clf;
end
disp('Analysis completed. Results stored in data folders.')
close;
end