function BehaviorName = genBehStruct(start_inds, stop_inds, numframes)

    BehaviorName.Bouts = []; % Initialize structure

    while length(start_inds) ~= length(stop_inds) % Make sure start_inds and stop_inds are same length
        disp('Mismatch in behavior start/stop vectors; check start_inds & stop_inds')
        disp('Pausing')
        pause
    end

    BehaviorName.Bouts(:, 1) = start_inds; % Assign start/stop inds to .Bouts
    BehaviorName.Bouts(:, 2) = stop_inds;
    
    BehaviorName.Count = size(BehaviorName.Bouts, 1); % Count number of bouts
    BehaviorName.Length = stop_inds - start_inds; % Calculate frame-wise length of bouts
    BehaviorName.Vector = zeros(1, numframes); % Initialize behavior vector

    % Generate binarized behavior vector
    for i = 1:BehaviorName.Count
        BehaviorName.Vector(BehaviorName.Bouts(i,1):BehaviorName.Bouts(i,2)) = 1;
    end
    
end