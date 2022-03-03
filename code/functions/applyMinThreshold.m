% applyMinThreshold

% Apply a minimum duration threshold (in seconds) to start/stop event data

% INPUTS: 4 inputs: start_inds, stop_inds, minDuration, frameRate    OR...
%         3 inputs: [start_inds, stop_inds], minDuration, frameRate

% OUTPUTS: start/stop inds, either as a matrix (1 output) or vectors (2
%          outputs)

function [varargout] = applyMinThreshold(varargin)

    nInputs = nargin;
    
    if nInputs == 4
        start_inds = varargin{1};
        stop_inds = varargin{2};
    elseif nInputs == 3
        start_inds = varargin{1}(:,1);
        stop_inds = varargin{1}(:,2);
    end
        minDuration = varargin{nInputs-1};
        frameRate = varargin{nInputs};

    % Adjust minimum duration
    if length(start_inds) > length(stop_inds)
        start_inds = start_inds(1:end-1);
    end
    
    for i = 1:length(start_inds)
        if stop_inds(i) - start_inds(i) < round(frameRate .* minDuration) %set the minimum duration here
            start_inds(i) = NaN; stop_inds(i) = NaN;
        end
    end
    
    inds_to_delete = find(isnan(start_inds));
    start_inds(inds_to_delete) = [];
    stop_inds(inds_to_delete) = [];
    
    nOutputs = nargout;
    varargout = cell(1, nOutputs);
    
    if nOutputs == 1 
        varargout{1} = [start_inds, stop_inds];

    elseif nOutputs == 2
        varargout{1} = start_inds;
        varargout{2} = stop_inds;
    end
end