% Elevated Plus Maze Classifier
% C.G. 1/28/22
% Contact: cjgabrie@ucla.edu

%INPUT: Params, Tracking, Metrics (from BehaviorDEPOT output)
%OUTPUT: EPM Structure

%FUNCTION: Classify total & percent time (in s), distance traveled (in cm), and number of
%entries into each ROI

%PARAMS:
% 1) ROIS:
    % a) O1, first open arm ROI
    % b) O2, second open arm ROI
    % c) C1, first closed arm ROI
    % d) C2, second closed arm ROI
    % e) Center, center ROI

function EPM = calculateEPM(Params, ~, Metrics)

% Set total frames
numFrames = Params.numFrames;
fps = Params.Video.frameRate;

% Set Open Arms ROIs
open1 = Params.EPM.O1.inROIvector;
open2 = Params.EPM.O2.inROIvector;

% Set Closed Arms ROIs
closed1 = Params.EPM.C1.inROIvector;
closed2 = Params.EPM.C2.inROIvector;

% Set Center ROI
center = Params.EPM.Center.inROIvector;

% Generate Vectors for All Open and All Closed Arms
all_open = open1 | open2;
all_closed = closed1 | closed2;

% Collect all ROIs
all_ROIs = {all_open, all_closed, center, open1, open2, closed1, closed2};
roi_names = {'Open', 'Closed', 'Center', 'O1', 'O2', 'C1', 'C2'};

%% Analysis

dist_traveled_frame = Metrics.Movement.DistanceTraveled;

for i = 1:length(all_ROIs)
    % Calculate percent time in each arm (o1, o2, c1, c2) + center
    EPM.(roi_names{i}).TotalTime = sum(all_ROIs{i}) / fps;
    EPM.(roi_names{i}).PercentTime = sum(all_ROIs{i}) / numFrames;
    
    % Collect start/stop inds for each roi
    roi_bouts = findStartStop(all_ROIs{i});
    
    % Calculate # of Entries into each ROI
    EPM.(roi_names{i}).Entries = size(roi_bouts, 1);
    
    % Calculate distance traveled in each ROI
    for ii = 1:size(roi_bouts, 1)
        dist_count = zeros(size(roi_bouts));
        dist_count(:,1) = dist_traveled_frame(roi_bouts(:,1));
        dist_count(:,2) = dist_traveled_frame(roi_bouts(:,2));
        EPM.(roi_names{i}).BoutDist = dist_count(:,2) - dist_count(:,1);
        EPM.(roi_names{i}).DistTraveled = sum(EPM.(roi_names{i}).BoutDist);
    end
end

% Can we detect head dips?

% Make a results table per ROI
TotalTime = zeros(size(all_ROIs'));
PercentTime = zeros(size(all_ROIs'));
DistTraveled = zeros(size(all_ROIs'));
Entries = zeros(size(all_ROIs'));

for i = 1:length(all_ROIs)
    TotalTime(i,1) = EPM.(roi_names{i}).TotalTime;
    PercentTime(i,1) = EPM.(roi_names{i}).PercentTime;
    DistTraveled(i,1) = EPM.(roi_names{i}).DistTraveled;
    Entries(i,1) = EPM.(roi_names{i}).Entries;
end

EPM.Results = table(TotalTime, PercentTime, DistTraveled, Entries, 'RowNames', roi_names);

end