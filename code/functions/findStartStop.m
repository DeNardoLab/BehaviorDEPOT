% OUTPUT: start_inds, stop_inds

function [varargout] = findStartStop(binary_vector)

    % Take differential of binary_vector
    diff_vector = diff(binary_vector);
    
    % Adjust diffential to match length & check if 1st frame is 1/0
    if binary_vector(1) == 1
        diff_vector = [1 diff_vector];
    elseif binary_vector(1) == 0
        diff_vector = [0 diff_vector];
    end

    % Adjust diffential if last frame is positive
    if binary_vector(end) == 1
        diff_vector = [diff_vector -1];
    end
    
    % Extract start and stop inds from diff_vector (start frame = 1; stop (+ 1) frame = -1)
    start_inds = find(diff_vector' == 1);
    stop_inds = find(diff_vector' == -1) - 1;
    
    nOutputs = nargout;
    varargout = cell(1, nOutputs);
    
    if nOutputs == 1 
        varargout{1} = [start_inds, stop_inds];
    elseif nOutputs == 2
        varargout{1} = start_inds;
        varargout{2} = stop_inds;
    end

end