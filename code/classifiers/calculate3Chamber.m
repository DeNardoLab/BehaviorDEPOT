% Three-Chamber Classifier
% C.G. 3/12/22
% Contact: cjgabrie@ucla.edu

%INPUT: Params, Tracking, Metrics (from BehaviorDEPOT output)
%OUTPUT: ThreeChamber Structure

% FUNCTION: Classify total & percent time (in s), distance traveled (in cm), and number of
%           entries into each ROI

% PARAMS:

% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) ROI_Labels:
    % a) Chamber1
    % b) Chamber2
    % c) Chamber3

function ThreeChamber = calculateThreeChamber(Params, ~, Metrics)

% Set total frames
numFrames = Params.numFrames;
fps = Params.Video.frameRate;

% Set ROIs
c1 = Params.ThreeChamber.Chamber1.inROIvector;
c2 = Params.ThreeChamber.Chamber2.inROIvector;
c3 = Params.ThreeChamber.Chamber3.inROIvector;

% Collect all ROIs
all_ROIs = {c1, c2, c3};
roi_names = {'Chamber1', 'Chamber2', 'Chamber3'};

% Convolve raw in-ROI vectors
for i = 1:length(all_ROIs)
    all_ROIs{i} = convolveFrames(all_ROIs{i}, Params.ThreeChamber.windowWidth, Params.ThreeChamber.countThreshold);
end

%% Analysis

dist_traveled_frame = Metrics.Movement.DistanceTraveled;

for i = 1:length(all_ROIs)
    % Calculate percent time in each chamber
    ThreeChamber.(roi_names{i}).Bouts = findStartStop(all_ROIs{i});
    ThreeChamber.(roi_names{i}).Vector = all_ROIs{i};
    ThreeChamber.(roi_names{i}).TotalTime = sum(all_ROIs{i}) / fps;
    ThreeChamber.(roi_names{i}).PercentTime = sum(all_ROIs{i}) / numFrames;
    
    % Collect start/stop inds for each roi
    roi_bouts = findStartStop(all_ROIs{i});
    
    % Calculate # of Entries into each ROI
    ThreeChamber.(roi_names{i}).Entries = size(roi_bouts, 1);
    
    % Calculate distance traveled in each ROI
    for ii = 1:size(roi_bouts, 1)
        dist_count = zeros(size(roi_bouts));
        dist_count(:,1) = dist_traveled_frame(roi_bouts(:,1));
        dist_count(:,2) = dist_traveled_frame(roi_bouts(:,2));
        ThreeChamber.(roi_names{i}).BoutDist = dist_count(:,2) - dist_count(:,1);
        ThreeChamber.(roi_names{i}).DistTraveled = sum(ThreeChamber.(roi_names{i}).BoutDist);
    end
end

% Make a results table per ROI
TotalTime = zeros(size(all_ROIs'));
PercentTime = zeros(size(all_ROIs'));
DistTraveled = zeros(size(all_ROIs'));
Entries = zeros(size(all_ROIs'));

for i = 1:length(all_ROIs)
    TotalTime(i,1) = ThreeChamber.(roi_names{i}).TotalTime;
    PercentTime(i,1) = ThreeChamber.(roi_names{i}).PercentTime;
    DistTraveled(i,1) = ThreeChamber.(roi_names{i}).DistTraveled;
    Entries(i,1) = ThreeChamber.(roi_names{i}).Entries;
end

ThreeChamber.Results = table(TotalTime, PercentTime, DistTraveled, Entries, 'RowNames', roi_names);

end