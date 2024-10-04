%% BehaviorDEPOT Data Prep Module
% C.G. 2/24/22

% PURPOSE: Import user input from BehaviorDEPOT GUI (stored in P) and apply
% to run 'j'; performs pose registration, ROI drawing interface, data smoothing/interpolation, and metric calculation 

% INPUTS:
% P: Structure array of user parameters imported from GUI
% j: Counting variable (integer) for batch analysis runs

% OUTPUTS:
% Params: Structure array of parameters for current run
% Tracking: Structure array of raw and smoothed pose tracking data
% Metrics: Structure array of extracted metrics from registered animal
% P: User input structure to be run on future runs; includes updates for
%    reused-ROI and part registration 

function [Params, Tracking, Metrics, P] = BD_dataPrep(P, j)

%% Select current dataset
video_file = P.video_file{j};
tracking_file = P.tracking_file{j};

%% Run video interface
[Frame, P] = videoInterface(video_file, P);
frame_ids = fieldnames(Frame);
frame_idx = frame_ids{randi(5,1)};
frame = Frame.(frame_idx);

%% Draw Custom ROIs
P = drawROIs(Frame, P);

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
