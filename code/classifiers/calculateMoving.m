function out = calculateMoving(Metrics, Params)

    dist = Metrics.Movement_cmpersec;
    vector = zeros(size(dist));
    bouts = find(dist >= Params.Moving.minSpeed);
    vector(bouts) = 1;

    out.Vector = vector;
    
    state_chg = [true, diff(out.Vector') ~= 0, true];  % find changes in behavior vector
    out.Count = numel(find(state_chg==1)) - 1; % count number of changes (less one for initial state)
    out.Length = diff(find(state_chg)); % Number of repetitions
    
    t = out.Vector';% look for bouts
    out.Bouts(:,1) = findstr([0 t], [0 1])-1;  %gives indices of beginning of groups
    out.Bouts(:,2) = findstr([t 0], [1 0]);    %gives indices of end of groups

end