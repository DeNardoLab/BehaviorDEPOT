function Rearing = calculateRearing(Tracking, Params)
try 
    loc = Tracking.Smooth.Head;
    % find frames when head location is outside floor boundaries
    head_out_floor = ~inpolygon(loc(1,:),loc(2,:),Params.arena_floor(:,1),Params.arena_floor(:,2));  

    % find frames when tailbase is within floor boundaries
    tb = Tracking.Smooth.Tailbase;
catch
    error('Rearing classifier requires Head (or Ears and Nose) and Tailbase to be tracked');
end

tail_in_floor = inpolygon(tb(1,:),tb(2,:),Params.arena_floor(:,1),Params.arena_floor(:,2));  

% find frames when head is outside floor boundaries and tailbase is within
rear_frames = find(head_out_floor == 1 & tail_in_floor == 1);
Rearing.Vector = zeros(1,length(loc));
Rearing.Vector(rear_frames) = 1;
Rearing.Vector = Rearing.Vector';
Rearing.PerTime = sum(Rearing.Vector) / length(Rearing.Vector);

state_chg = [true, diff(Rearing.Vector') ~= 0, true];  % find changes in behavior vector
Rearing.Count = numel(find(state_chg==1)) - 1; % count number of changes (less one for initial state)
Rearing.Length = diff(find(state_chg)); % Number of repetitions

t = Rearing.Vector';% look for bouts
Rearing.Bouts(:,1) = findstr([0 t], [0 1])-1;  %gives indices of beginning of groups
Rearing.Bouts(:,2) = findstr([t 0], [1 0]);    %gives indices of end of groups
end