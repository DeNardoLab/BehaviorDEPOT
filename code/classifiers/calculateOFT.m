% Open Field Test Classifier
% C.G. 2/17/22
% Contact: cjgabrie@ucla.edu

%INPUT: Params, Tracking, Metrics (from BehaviorDEPOT output)
%OUTPUT: OFT Structure

%FUNCTION: Classify total & percent time (in s), distance traveled (in cm), and number of
%entries into each ROI

%PARAMS:
% 1) ROIS:
    % a) Arena, ROI around the full arena
    % b) Center, ROI around the center of the arena

function OFT = calculateOFT(Params, ~, Metrics)

% Set total frames
numFrames = Params.numFrames;
fps = Params.Video.frameRate;

% Set arena and center ROIs
arena = Params.OFT.Arena.inROIvector;
center = Params.OFT.Center.inROIvector;

% Generate vector for periphery (peri)
peri = arena - center;

% Collect all ROIs
all_ROIs = {center, peri, arena};
roi_names = {'Center', 'Peri', 'Arena'};

%% Analysis

dist_traveled_frame = Metrics.Movement.DistanceTraveled;

for i = 1:length(all_ROIs)
    % Calculate percent time in arena, perimeter, center
    OFT.(roi_names{i}).Bouts = findStartStop(all_ROIs{i});
    OFT.(roi_names{i}).Vector = all_ROIs{i};
    OFT.(roi_names{i}).TotalTime = sum(all_ROIs{i}) / fps;
    OFT.(roi_names{i}).PercentTime = sum(all_ROIs{i})/numFrames;
    
    % Collect start/stop inds for each roi
    roi_bouts = findStartStop(all_ROIs{i});
    
    % Calculate # of Entries into each ROI
    OFT.(roi_names{i}).Entries = size(roi_bouts, 1);
    
    % Calculate distance traveled in each ROI
    for ii = 1:size(roi_bouts, 1)
        dist_count = zeros(size(roi_bouts));
        dist_count(:,1) = dist_traveled_frame(roi_bouts(:,1));
        dist_count(:,2) = dist_traveled_frame(roi_bouts(:,2));
        OFT.(roi_names{i}).BoutDist = dist_count(:,2) - dist_count(:,1);
        OFT.(roi_names{i}).DistTraveled = sum(OFT.(roi_names{i}).BoutDist);
    end
end

% Make a results table per ROI
TotalTime = zeros(size(all_ROIs'));
PercentTime = zeros(size(all_ROIs'));
DistTraveled = zeros(size(all_ROIs'));
Entries = zeros(size(all_ROIs'));

for i = 1:length(all_ROIs)
    TotalTime(i,1) = OFT.(roi_names{i}).TotalTime;
    PercentTime(i,1) = OFT.(roi_names{i}).PercentTime;
    DistTraveled(i,1) = OFT.(roi_names{i}).DistTraveled;
    Entries(i,1) = OFT.(roi_names{i}).Entries;
end

OFT.Results = table(TotalTime, PercentTime, DistTraveled, Entries, 'RowNames', roi_names);

end