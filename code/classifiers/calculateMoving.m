function Moving = calculateMoving(Params, ~, Metrics)

    dist = Metrics.Movement.Data;
    temp_vector = zeros(size(dist));
    moving_inds = dist >= Params.Moving.minSpeed;
    temp_vector(moving_inds) = 1;

    [moveStart, moveStop] = findStartStop(temp_vector);
    [moveStart, moveStop] = applyMinThreshold(moveStart, moveStop, Params.Moving.minDuration, Params.Video.frameRate);

    % Generate Behavior Structure
    Moving = genBehStruct(moveStart, moveStop, Params.numFrames);

end