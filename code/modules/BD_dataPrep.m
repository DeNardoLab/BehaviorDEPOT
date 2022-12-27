function [Params, Tracking, Metrics, P] = BD_dataPrep(P, j)

%% Select current dataset
video_file = P.video_file{j};
tracking_file = P.tracking_file{j};

%% Run video interface
[Frame, P] = videoInterface(video_file, P);
frame_ids = fieldnames(Frame);
frame_idx = frame_ids{randi(5,1)};
frame = Frame.(frame_idx);
frame_idx = str2num(frame_idx(2:end));

%% Draw ROIs included in specific classifiers
P = drawClassROIs(P, frame);

%% Save parameters to Params structure
Params = makeParamsStruct(P);
Params.basedir = P.basedir;
Params.tracking_file = tracking_file;
Params.video_file = video_file;
Params.Frame = Frame;

%% CSV/H5 Registration
[data, Params] = importTracking(Params);
Params.numFrames = size(data, 2);

%% Convert data to Tracking structure and apply hampel correction
cd(P.script_dir);
Tracking = genTracking_custom(data, Params);
disp(['Tracked ' num2str(length(Params.part_names)) ' points']);

%% Smooth Tracking Data
Tracking = smoothTracking_custom(Tracking, Params);

%% Visual verification of point tracking and body part indexing
Plots.pointValidation = plotPointTracking(Tracking, Params, frame, frame_idx);

%% Metric Calculations
[Metrics, Tracking, Params, P] = calculateMetrics(Tracking, Params, P);

end
