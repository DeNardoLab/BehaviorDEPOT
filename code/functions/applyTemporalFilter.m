% applyTemporalFilter()
% C.G. 3/21/22
% Contact: cjgabrie@ucla.edu

% FUNCTION: read a cue file and convert to vector form

function output = applyTemporalFilter(Params, event_name, event_file)
    
% Initialization
numFrames = Params.numFrames;

% load event times
eventmat = readmatrix(event_file);

% convert event times to vector
output = genBehStruct(eventmat(:,1), eventmat(:,2), numFrames);

end