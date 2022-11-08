% T-Maze Classifier
% C.G. 3/1/22
% Contact: cjgabrie@ucla.edu

%INPUT: Params, Tracking, Metrics (from BehaviorDEPOT output)
%OUTPUT: TMaze Structure

% FUNCTION: Classify total & percent time (in s), distance traveled (in cm), and number of
%           entries into each ROI

% PARAMS:

% 1) windowWidth: for convolving inROI vectors
% 2) countThreshold: for convolving inROI vectors
% 3) ROI_Labels:
    % a) Approach
    % b) Choice
    % c) Effort_L
    % d) Effort_R
    % e) Reward_L
    % f) Reward_R

function TMaze = calculateTMaze(Params, ~, Metrics)

% Set total frames
numFrames = Params.numFrames;
fps = Params.Video.frameRate;

% Set ROIs
approach = Params.TMaze.Approach.inROIvector;
choice = Params.TMaze.Choice.inROIvector;
effortL = Params.TMaze.Effort_L.inROIvector;
effortR = Params.TMaze.Effort_R.inROIvector;
rewardL = Params.TMaze.Reward_L.inROIvector;
rewardR = Params.TMaze.Reward_R.inROIvector;

% Make ROIs for all Effort and all Reward
all_effort = effortL | effortR;
all_reward = rewardL | rewardR;

% Collect all ROIs
all_ROIs = {approach, choice, effortL, effortR, rewardL, rewardR, all_effort, all_reward};
roi_names = {'Approach', 'Choice', 'Effort_L', 'Effort_R', 'Reward_L', 'Reward_R', 'All_Effort', 'All_Reward'};

% Convolve raw in-ROI vectors
for i = 1:length(all_ROIs)
    all_ROIs{i} = convolveFrames(all_ROIs{i}, Params.TMaze.windowWidth, Params.TMaze.countThreshold);
end

%% Analysis

dist_traveled_frame = Metrics.Movement.DistanceTraveled;

for i = 1:length(all_ROIs)
    % Calculate percent time in each arm (o1, o2, c1, c2) + center
    TMaze.(roi_names{i}).Bouts = findStartStop(all_ROIs{i});
    TMaze.(roi_names{i}).Vector = all_ROIs{i};
    TMaze.(roi_names{i}).TotalTime = sum(all_ROIs{i}) / fps;
    TMaze.(roi_names{i}).PercentTime = sum(all_ROIs{i}) / numFrames;
    
    % Collect start/stop inds for each roi
    roi_bouts = findStartStop(all_ROIs{i});
    
    % Calculate # of Entries into each ROI
    TMaze.(roi_names{i}).Entries = size(roi_bouts, 1);
    
    % Calculate distance traveled in each ROI
    for ii = 1:size(roi_bouts, 1)
        dist_count = zeros(size(roi_bouts));
        dist_count(:,1) = dist_traveled_frame(roi_bouts(:,1));
        dist_count(:,2) = dist_traveled_frame(roi_bouts(:,2));
        TMaze.(roi_names{i}).BoutDist = dist_count(:,2) - dist_count(:,1);
        TMaze.(roi_names{i}).DistTraveled = sum(TMaze.(roi_names{i}).BoutDist);
    end
end

% Make a results table per ROI
TotalTime = zeros(size(all_ROIs'));
PercentTime = zeros(size(all_ROIs'));
DistTraveled = zeros(size(all_ROIs'));
Entries = zeros(size(all_ROIs'));

for i = 1:length(all_ROIs)
    TotalTime(i,1) = TMaze.(roi_names{i}).TotalTime;
    PercentTime(i,1) = TMaze.(roi_names{i}).PercentTime;
    DistTraveled(i,1) = TMaze.(roi_names{i}).DistTraveled;
    Entries(i,1) = TMaze.(roi_names{i}).Entries;
end

TMaze.Results = table(TotalTime, PercentTime, DistTraveled, Entries, 'RowNames', roi_names);

end