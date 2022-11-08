% Platform-Mediated Avoidance Analysis Function
% C.G. 3/24/22
% Contact: cjgabrie@ucla.edu

%INPUT: Params, Tracking, Metrics (from BehaviorDEPOT output)
%OUTPUT: PMA Structure

%FUNCTION: Classify total & percent time (in s), distance traveled (in cm), and number of
%          entries into each ROI

%PARAMS:
% 1) ROIs:
    % a) Platform 

function PMA = calculatePMA(Params, ~, Metrics)

% Set total frames
numFrames = Params.numFrames;
fps = Params.Video.frameRate;

% Set Platform ROI
platform = Params.PMA.Platform.inROIvector;

% Convolve raw in-platform vector
platform = convolveFrames(platform, Params.PMA.windowWidth, Params.PMA.countThreshold);

% Find Tone file
start_dir = pwd;
cd(Params.basedir);
cue_search = dir('*cue*.csv');
cd(start_dir)

if size(cue_search, 1) == 1
    if ispc
        cue_file = [cue_search.folder, '\', cue_search.name];
    else
        cue_file = [cue_search.folder, '/', cue_search.name];
    end
end

% Set Tone Info
PMA.Tone = applyTemporalFilter(Params, Params.PMA.cue_name, cue_file);

%% Analysis
dist_traveled_frame = Metrics.Movement.DistanceTraveled;

% Calculate percent time and total time in platform
PMA.Platform.Bouts = findStartStop(platform);
PMA.Platform.Vector = platform;
PMA.Platform.TotalTime = sum(platform) / fps;
PMA.Platform.PercentTime = sum(platform) / numFrames;

% Calculate # of Entries into platform
PMA.Platform.Entries = size(PMA.Platform.Bouts, 1);

% Calculate distance traveled in each platform bout
dist_count = zeros(size(PMA.Platform.Bouts));
dist_count(:,1) = dist_traveled_frame(PMA.Platform.Bouts(:,1));
dist_count(:,2) = dist_traveled_frame(PMA.Platform.Bouts(:,2));
PMA.Platform.BoutDist = dist_count(:,2) - dist_count(:,1);
PMA.Platform.DistTraveled = sum(PMA.Platform.BoutDist);

%% TO UPDATE: Add tone/platform intersect calculations and visualizations




% Make a results table per ROI
TotalTime = zeros(size(all_ROIs'));
PercentTime = zeros(size(all_ROIs'));
DistTraveled = zeros(size(all_ROIs'));
Entries = zeros(size(all_ROIs'));

for i = 1:length(all_ROIs)
    TotalTime(i,1) = PMA.Platform.TotalTime;
    PercentTime(i,1) = PMA.Platform.PercentTime;
    DistTraveled(i,1) = PMA.Platform.DistTraveled;
    Entries(i,1) = PMA.Platform.Entries;
end

PMA.Results = table(TotalTime, PercentTime, DistTraveled, Entries, 'RowNames', roi_names);

end