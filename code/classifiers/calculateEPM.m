% Elevated Plus Maze Classifier
% C.G. 1/28/22
% Contact: cjgabrie@ucla.edu

%INPUT: Params, Tracking, Metrics (from BehaviorDEPOT output)
%OUTPUT: EPM Structure

%FUNCTION:

%PARAMS:
% 1) O1, first open arm ROI
% 2) O2, second open arm ROI
% 3) C1, first closed arm ROI
% 4) C2, second closed arm ROI
% 5) Center, center ROI

function EPM = calculateEPM(Params, Tracking, Metrics)

% Set total frames
numFrames = Params.numFrames;

% Set Open Arms ROIs
open1 = Params.EPM.O1.inROIvector;
open2 = Params.EPM.O2.inROIvector;

% Set Closed Arms ROIs
closed1 = Params.EPM.C1.inROIvector;
closed2 = Params.EPM.C2.inROIvector;

% Set Center ROI
center = Params.EPM.Center.inROIvector;

% Collect all ROIs
all_ROIs = {open1, open2, closed1, closed2, center};
roi_names = {'Open1', 'Open2', 'Closed1', 'Closed2', 'Center'};

% Generate Vectors for All Open and All Closed Arms
all_open = open1 | open2;
all_closed = closed1 | closed2;

%% Analysis

% Calculate percent time in each arm (o1, o2, c1, c2) + center

for i = 1:length(bloooooooooop)
    EPM.O1.PercentTime = sum(open1)/numFrames;
end

EPM.O1.PercentTime = sum(open1)/numFrames;
EPM.O2.PercentTime = sum(open2)/numFrames;
EPM.C1.PercentTime = sum(closed1)/numFrames;
EPM.C2.PercentTime = sum(closed2)/numFrames;
EPM.Center.PercentTime = sum(center)/numFrames;
EPM.Open.PercentTime = sum(all_open)/numFrames;
EPM.Closed.PercentTime = sum(all_closed)/numFrames;

% Calculate distance traveled in each arm + center
dist_traveled = Metrics.Movement.DistanceTraveled;

% Calculate number of open arm entries vs. closed arm entries
temp_bouts = Params.EPM.O1.Bouts;
entries = size(temp_bouts, 1);
EPM.O1.Entries = entries;

% Can we detect head dips?
% Make a results table per ROI

end