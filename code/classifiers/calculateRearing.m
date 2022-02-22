function Rearing = calculateRearing(Params, Tracking, Metrics)
try 
    loc = Tracking.Smooth.Head;
    % find frames when head location is outside floor boundaries
    head_out_floor = ~inpolygon(loc(1,:),loc(2,:),Params.arena_floor(:,1),Params.arena_floor(:,2));  

    % find frames when tailbase is within floor boundaries
    tb = Tracking.Smooth.Tailbase;
catch
    error('Rearing classifier requires Head (or Ears and Nose) and Tailbase to be tracked');
end

tailbase_in_floor = inpolygon(tb(1,:),tb(2,:),Params.arena_floor(:,1),Params.arena_floor(:,2));  
rearingInds = (head_out_floor == 1 & tailbase_in_floor == 1);

[rearStart, rearStop] = findStartStop(rearingInds);
[rearStart, rearStop] = applyMinThreshold(rearStart, rearStop, Params.Rearing.minDuration, Params.Video.frameRate);

%% Generate Behavior Structure
Rearing = genBehStruct(rearStart, rearStop, Params.numFrames);

end