function Moving = calculateMoving(Metrics, Params)

    dist = Metrics.Movement.Data;
    temp_vector = zeros(size(dist));
    moving_inds = find(dist >= Params.Moving.minSpeed);
    temp_vector(moving_inds) = 1;

    [moveStart, moveStop] = findStartStop(temp_vector);
    [moveStart, moveStop] = applyMinThreshold(moveStart, moveStop, Params.Moving.minDuration, Params);

    % Generate Behavior Structure
    Moving = genBehStruct(moveStart, moveStop, Params.numFrames);

end