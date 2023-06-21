% VTE TMaze Analysis Script
% Written by CJG, 8/30/21

% Pull Out Trial Structure from Post-BehaviorDEPOT T-Maze Videos
start_dir = pwd;
disp('Select BehaviorDEPOT _analyzed folder')
bdPath = uigetdir();
cd(bdPath)
load('Behavior')
load('Params')
load('Metrics')
cd(start_dir)

%% 

roi_names = fieldnames(Behavior.TMaze);

for i = 1:length(roi_names)
    if isa(Behavior.TMaze.(roi_names{i}), 'struct')
        all_rois.(roi_names{i}) = Behavior.TMaze.(roi_names{i});
    end
end

approachVector = all_rois.Approach.inROIvector;
choiceVector = all_rois.Choice.inROIvector;
try
    rightEffortVector = all_rois.RightEffort.inROIvector;
catch
    rightEffortVector = all_rois.EffortR.inROIvector;
end

try
    leftEffortVector = all_rois.LeftEffort.inROIvector;
catch
    leftEffortVector = all_rois.EffortL.inROIvector;
end

try
    rightRewardVector = all_rois.RightReward.inROIvector;
catch
    rightRewardVector = all_rois.RewardR.inROIvector;
end

try
    leftRewardVector = all_rois.LeftReward.inROIvector;
catch
    leftRewardVector = all_rois.RewardL.inROIvector;
end

%% Collect potential start and stop frames from approach and reward zone entries

fps = Params.Video.frameRate;
total_frames = Params.Video.totalFrames;

% Find Trials: Find all places where mice enter the approach ROI, as
% well as all places where they enter either Reward ROI

[aS, aE] = findStartStop(approachVector);
[rS, rE] = findStartStop(rightRewardVector | leftRewardVector);

% Potential trial start set as entries into Approach; potential trial ends
% set as entries into Reward
start_candidates = aS;
stop_candidates = rS;

% Use longer entry (start or stop) to try and find closest match
if length(start_candidates) < length(stop_candidates)
    c = 1;
    trials = [];
    for i = 1:length(start_candidates)
        start_ind = start_candidates(i);
        test = stop_candidates - start_ind;
        select_inds = find(test > 0);
        if select_inds > 0
            trials(c,:) = [start_ind, stop_candidates(select_inds(1))];
            c = c + 1;
        end
    end
    
else
    c = 1;
    trials = [];
    for i = 1:length(stop_candidates)
        stop_ind = stop_candidates(i);
        test = stop_ind - start_candidates;
        select_inds = find(test > 0);
        if select_inds > 0
            trials(c,:) = [start_candidates(select_inds(end)), stop_ind];
            c = c + 1;
        end
    end
end

%% Remove duplicate start/stops from trials

for i = 1:2
    data = trials(:,i);
    [uniq, uniq_inds] = unique(data, 'first');
    non_unique = 1:size(trials, 1);
    non_unique(uniq_inds) = [];
    remove_inds = [];
    
    for ii = 1:size(non_unique, 2)
        multi_inds = find(data == data(non_unique(ii))); 
        sort_trial = trials(multi_inds, :);
        sort_test = sort_trial(:,2) - sort_trial(:,1);
        [choice, choice_ind] = min(abs(sort_test - 2.5*fps));
        remove_inds = [remove_inds; multi_inds(multi_inds ~= multi_inds(choice_ind))];
    end
    remove_inds = unique(remove_inds);
    trials(remove_inds, :) = [];
end

%% Filter Trials by Inter-Trial Interval
% Remove trials where previous ITI is less than ITI_thresh

%ITI_thresh = 2200;
ITI = trials(2:end,1) - trials(1:end-1, 2);

ITI_avg = nanmean(ITI);
ITI_std = std(ITI);
ITI_thresh = ITI_avg - ITI_std;

to_remove = find(ITI < ITI_thresh) + 1; 
trials(to_remove, :) = [];

%% Determine Trial Choice & Time per ROI

% 1 = Right Arm
% 0 = Left Arm

choice = zeros(size(trials, 1), 1);
choice_cell = cell(size(trials, 1), 1);
vte_trials = zeros(size(trials, 1), 1);
totalTimeApproach = zeros(size(trials, 1), 1);
totalTimeChoice = zeros(size(trials, 1), 1);
totalTimeREffort = zeros(size(trials, 1), 1);
totalTimeRReward = zeros(size(trials, 1), 1);
totalTimeLEffort = zeros(size(trials, 1), 1);
totalTimeLReward = zeros(size(trials, 1), 1);
headScans = zeros(size(trials, 1), 1);

headAngles = Metrics.degHeadAngle;
angleBin = cell(size(choiceVector));

for i = 1:size(choiceVector, 2)

    if 80 > headAngles(i) & headAngles(i) > -80
        angleBin{i} = 'R';
    elseif headAngles(i) > 100 | headAngles(i) < -100
        angleBin{i} = 'L';
    end

end

for i = 1:size(trials, 1)
    trial_inds = trials(i, :);
    trial_span = [trial_inds(1):trial_inds(2)];
    rScore = sum(rightRewardVector(trial_inds));
    lScore = sum(leftRewardVector(trial_inds));
    if rScore > lScore
        choice(i) = 1;
        choice_cell{i} = 'Right';
    elseif rScore < lScore
        choice(i) = 0;
        choice_cell{i} = 'Left';
    else
        choice(i) = NaN;
        choice_cell{i} = NaN;
    end
    
    trial_range = [trials(i,1) : trials(i,2)];
    trial_choice_range = choiceVector(trial_range);
    trial_choice_f = find(trial_choice_range);
    trial_choice_frames = trial_range(trial_choice_f);
    trial_directions = angleBin(trial_choice_frames);
    
    head_scans = 0;
    for ii = 2:size(trial_directions, 2)
        if ~strcmp(trial_directions(ii), trial_directions(ii-1))
            head_scans = head_scans + 1;
        end
    end
    
    headScans(i) = head_scans;
    totalTimeApproach(i) = sum(approachVector(trial_span));
    totalTimeChoice(i) = sum(choiceVector(trial_span));
    totalTimeREffort(i) = sum(rightEffortVector(trial_span));
    totalTimeLEffort(i) = sum(leftEffortVector(trial_span));
    totalTimeRReward(i) = sum(rightRewardVector(trial_span));
    totalTimeLReward(i) = sum(leftRewardVector(trial_span));
end

vte_trials = (totalTimeChoice >= 0.5*fps) | (headScans > 3);
vteChoice = cell(size(vte_trials));

for i = 1:size(vte_trials, 1)
    if vte_trials(i) == 1
        vteChoice{i} = 'Yes';
    elseif vte_trials(i) == 0
        vteChoice{i} = 'No';
    end
end
        

%% Import Trial Information
try
    disp('Select CSV file associated with current session')
    csvFile = uigetfile('*.csv');
    Trials = readtable(csvFile);
catch
    Trials = table();
end

if size(Trials,1) == size(trials, 1) | size(Trials,1) == 0
    Trials.Start = trials(:,1);
    Trials.Stop = trials(:,2);
    Trials.AutoChoice = choice_cell;
    Trials.VTE = vteChoice;
    Trials.HeadScans = headScans;
    Trials.ApproachTime = totalTimeApproach;
    Trials.ChoiceTime = totalTimeChoice;
    Trials.R_EffortTime = totalTimeREffort;
    Trials.L_EffortTime = totalTimeLEffort;
    Trials.R_RewardTime = totalTimeRReward;
    Trials.L_RewardTime = totalTimeLReward;
else
    disp('Error: detected trials and CSV trial mismatch--ensure "trials" variable contains the expected number of trials')
    return;
end

%% Plot all ROIs

trial = 4;
frames = trials(trial,1):trials(trial,2);
allVectors = [approachVector(frames); choiceVector(frames); rightEffortVector(frames); rightRewardVector(frames); leftEffortVector(frames); leftRewardVector(frames)];
figure;
imagesc(allVectors)
yticks([1:6])
%yticklabels(roi_names)
yticklabels({'Approach', 'Choice', 'EffortR', 'RewardR', 'EffortL', 'RewardL'});
