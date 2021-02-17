function BehDepo_mainscript_single(P)
%% Additional parameters

%Adjustable Parameters
P.hmpl = 1; %Apply hampel transformation to DLC data (outlier correction); 1 = On
P.cutoffThreshold = 0.1; % Minimum confidence value for retaining DLC-tracked points based on DLC p-value; throws out values from 0 to chosen threshold

%Smoothing Parameters
%% %%%%%%%%-UPDATE TO SET IN GUI-%%%%%%%%%%
P.smoothMethod = 'lowess';
P.smoothSpan = 5;
%% %%%%%%%%----------------------%%%%%%%%%%

% Behavior Classification Parameters
% Freezing Parameters
% P.freezing_minDuration = 0.90; % set in GUI
% P.freezing_velocityThreshold = 0.38; % set in GUI
% P.freezing_angleThreshold = 0.27; % set in GUI
P.freezing_windowWidth = P.freezing_minDuration * 0.7; % empirically-determined
P.freezing_countThreshold = 0.15; % empirically-determined
P.part_save = "No";
P.part_lookup = [];
P.reuse_cue_name = 0;

%% Setup
% Collect 'video_folder_list' from 'P.video_directory'
P.script_dir = pwd; % directory with script files (avoids requiring changes to path)
disp('Select tracking file'); % point to folder for analysis
[ft pt] = uigetfile('*.*','Select tracking file');
disp('Select video file'); % point to folder for analysis
[fv pv] = uigetfile('*.*','Select video file');

P.tracking_file = [pt ft];
P.video_file = [pv fv];

    %% Collect frames for plots and draw ROIs
    [frame, frame1, frame_idx, P] = videoInterface([pv fv], P);
    
    %% Save parameters to Params structure
    Params = makeParamsStruct(P);    
    Params.basedir = pt;    
    %% CSV/H5 Registration
    Params.tracking_file = P.tracking_file;
    Params.video_file = P.video_file;
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
    analyzed_folder_name = string([[pv fv],'_analyzed']);
    saveAnalysis(analyzed_folder_name, Params, Tracking, Metrics, Behavior, Behavior_Filter) 
    
    %% VISUALIZATIONS
    % plot freezing bouts
    plot_bouts(Behavior, analyzed_folder_name);
    
    % plot trajectory map
    plotTrajectoryMap(Metrics, frame1, Params, Behavior, analyzed_folder_name);
    
    disp('Analysis completed. Results stored in data folder.')

end