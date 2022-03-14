function Rearing = calculateRearing(Params, ~, ~)

% Set total frames
numFrames = Params.numFrames;
fps = Params.Video.frameRate;

% Set arena_floor ROI
in_arena = Params.Rearing.Arena_Floor.inROIvector;

% Convolve raw in-ROI vectors
in_arena = convolveFrames(in_arena, Params.Rearing.windowWidth, Params.Rearing.countThreshold);

% Find rearingInds
rearing_vector = ~in_arena;

[rearStart, rearStop] = findStartStop(rearing_vector);
[rearStart, rearStop] = applyMinThreshold(rearStart, rearStop, Params.Rearing.minDuration, fps);

%% Generate Behavior Structure
Rearing = genBehStruct(rearStart, rearStop, numFrames);

end