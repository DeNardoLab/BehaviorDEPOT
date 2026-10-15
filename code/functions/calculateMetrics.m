%calculateMetrics

%INPUT: Tracking structure
%OUTPUT: Metrics structure

%FUNCTION: Calculate useful metrics for animal behavior classification
%using the smoothed tracking data from Tracking

function [Metrics, Tracking, Params, P] = calculateMetrics(Tracking, Params, P, varargin)
    %% Register tracked parts with custom names to known body parts
    
    % known_part_list contains list of tracking points of interest. Additional points can be added.
    % part_lookup(i) refers to the i_th field in Tracking.Smooth, and returns the ordered
    % assignment from known_part_list
    
    % Example: if known_part_list(8), 'Tailbase', is tracked in the 4th field of Tracking.Smooth,
    % part_lookup(4) returns 8
    
    if ~isfield(P, 'noninteractive')
        P.noninteractive = false;
    end
    if ~isfield(P, 'part_save')
        P.part_save = [];
    end

    if P.batchSession == 0 && ~P.noninteractive
        P.part_save = "No";
    end
    
    part_names = Params.part_names;
    known_part_list = {'Nose', 'Left Ear', 'Right Ear', 'BetwEars', 'Head', 'Neck', 'MidBack', 'RearBack', 'Left Leg', 'Right Leg', 'BetwLegs', 'Tailbase', 'Tail', 'Implant', 'Center', 'Other'};
    struct_part_list = strrep(known_part_list, ' ', '_');
    preview_frame = [];
    preview_frame_idx = [];
    if numel(varargin) >= 2
        preview_frame = varargin{1};
        preview_frame_idx = varargin{2};
    end

    % Prompt user to register body parts, then ask if want to save that list for future use
    registeredParts = false;
    if isfield(P, 'part_match_inds') && ~isempty(P.part_match_inds)
        part_match_inds = P.part_match_inds;
    elseif P.noninteractive
        error('BehaviorDEPOT:calculateMetrics:MissingPartRegistration', ...
            'Noninteractive runs require P.part_match_inds.');
    elseif isempty(P.part_save) || isequal(P.part_save, "No")
        default_part_match_inds = loadPartLookupDefaults( ...
            localPartLookupFolder(P), part_names, known_part_list);
        part_match_inds = registerTrackedParts( ...
            part_names, known_part_list, Tracking, preview_frame, preview_frame_idx, ...
            default_part_match_inds);
        registeredParts = true;
    else
        part_match_inds = P.part_match_inds;
    end

    validatePartMatchInds(part_match_inds, known_part_list, numel(part_names));

    if registeredParts
        savePartLookupDefaults(localPartLookupFolder(P), part_names, ...
            part_match_inds, known_part_list);
    end

    if isempty(P.part_save) && ~P.noninteractive
         dlgTitle    = 'Part list save';
         dlgQuestion = 'Do you wish to use the same part list for all batched analyses?';
         P.part_save = questdlg(dlgQuestion, dlgTitle, "Yes", "No", "Yes");
         
         if P.part_save == "Yes"
             P.part_match_inds = part_match_inds;
         else
             P.part_match_inds = [];
         end
    elseif P.noninteractive
        P.part_save = "Yes";
        P.part_match_inds = part_match_inds;
    end
    
    % create new struct to refer to tracked parts with known names. 
    % 'Other' tracked parts are assigned their original name 
    % assigns untracked parts from struct_part_list as empty
    trackcell = struct2cell(Tracking.Smooth);
    tempTracking = struct;

    % Scan through each known part
    for i = 1:length(struct_part_list)
        match_check = find(part_match_inds == i);
        % Check if there is a match for current known part (match_check)
        if ~isempty(match_check)
            % If not 'Other', save to tempTracking with registered part
            if ~strcmp(struct_part_list{i}, 'Other')
                tempTracking.(struct_part_list{i}) = trackcell{match_check};
            % If 'Other', save to tempTracking with original name
            else
                for ii = match_check
                    tempTracking.(part_names{ii}) = trackcell{ii};
                end
            end
        else
            tempTracking.(struct_part_list{i}) = [];
        end
    end

    %% METRIC CALCULATIONS
    % When adding new metrics, use tempTracking struct to perform
    % calculations
    
    %% Calculate point between ears (BetwEars)
    if isempty(tempTracking.BetwEars)
        if ~isempty(tempTracking.Left_Ear) && ~isempty(tempTracking.Right_Ear)
                tempTracking.BetwEars(1,:) = (tempTracking.Left_Ear(1,:) + tempTracking.Right_Ear(1,:))/2;
                tempTracking.BetwEars(2,:) = (tempTracking.Left_Ear(2,:) + tempTracking.Right_Ear(2,:))/2;
        end
    end
    
    %% Calculate point between legs (Left_Leg & Right_Leg)
    if isempty(tempTracking.BetwLegs)
        if ~isempty(tempTracking.Left_Leg) && ~isempty(tempTracking.Right_Leg)
                tempTracking.BetwLegs(1,:) = (tempTracking.Left_Leg(1,:) + tempTracking.Right_Leg(1,:))/2;
                tempTracking.BetwLegs(2,:) = (tempTracking.Left_Leg(2,:) + tempTracking.Right_Leg(2,:))/2;
        end
    end

    %% Calculate Head position from Left_Ear, Right_Ear, & Nose
    if isempty(tempTracking.Head)
        if ~isempty(tempTracking.Left_Ear) && ~isempty(tempTracking.Right_Ear) && ~isempty(tempTracking.Nose)
            tempTracking.Head(1,:) = (tempTracking.Nose(1,:) + tempTracking.Left_Ear(1,:) + tempTracking.Right_Ear(1,:))/3;
            tempTracking.Head(2,:) = (tempTracking.Nose(2,:) + tempTracking.Left_Ear(2,:) + tempTracking.Right_Ear(2,:))/3;
        else
            tempTracking.Head = tempTracking.BetwEars;
        end
    end
    
    %% Calculate Head Position Using Head-Mounted Implant
    if ~isempty(tempTracking.Left_Ear) && ~isempty(tempTracking.Right_Ear) && ~isempty(tempTracking.Implant)
        tempTracking.Head_Implant(1,:) = (tempTracking.Implant(1,:) + tempTracking.Left_Ear(1,:) + tempTracking.Right_Ear(1,:))/3;
        tempTracking.Head_Implant(2,:) = (tempTracking.Implant(2,:) + tempTracking.Right_Ear(2,:) + tempTracking.Left_Ear(2,:))/3;
    end
    
    %% Calculate MidBack from BetwEars, BetwLegs, and/or Tailbase, if not tracked directly (MidBack)
    if isempty(tempTracking.MidBack) && ~isempty(tempTracking.BetwEars)
        if ~isempty(tempTracking.BetwLegs)
            tempTracking.MidBack(1,:) = (tempTracking.BetwEars(1,:) + tempTracking.BetwLegs(1,:))/2;
            tempTracking.MidBack(2,:) = (tempTracking.BetwEars(2,:) + tempTracking.BetwLegs(2,:))/2;
        elseif ~isempty(tempTracking.Tailbase)
            tempTracking.MidBack(1,:) = (tempTracking.BetwEars(1,:) + tempTracking.Tailbase(1,:))/2;
            tempTracking.MidBack(2,:) = (tempTracking.BetwEars(2,:) + tempTracking.Tailbase(2,:))/2;
        end
    end
        
    %% Calculate BetwShoulders position from Left_Ear, Right_Ear, and MidBack (BetwShoulders)
    if ~isempty(tempTracking.Left_Ear) && ~isempty(tempTracking.Right_Ear) && ~isempty(tempTracking.MidBack)
        tempTracking.BetwShoulders(1,:) = (tempTracking.Left_Ear(1,:) + tempTracking.Right_Ear(1,:) + tempTracking.MidBack(1,:))/3;
        tempTracking.BetwShoulders(2,:) = (tempTracking.Left_Ear(2,:) + tempTracking.Right_Ear(2,:) + tempTracking.MidBack(2,:))/3;
    end

    %% Calculate RearBack position from Left_Leg, Right_Leg, and Tailbase (RearBack)
    if isempty(tempTracking.RearBack)
        if ~isempty(tempTracking.Left_Leg) && ~isempty(tempTracking.Right_Leg) && ~isempty(tempTracking.Tailbase)
            tempTracking.RearBack(1,:) = (tempTracking.Left_Leg(1,:) + tempTracking.Right_Leg(1,:) + tempTracking.Tailbase(1,:))/3;
            tempTracking.RearBack(2,:) = (tempTracking.Left_Leg(2,:) + tempTracking.Right_Leg(2,:) + tempTracking.Tailbase(2,:))/3;
        end
    end

    %% Initialize Metrics Structure
    Metrics = struct();

    %% Calculate Postural Metrics
    % Nose-Tailbase Distance
    if ~isempty(tempTracking.Tailbase) && ~isempty(tempTracking.Nose)
        Metrics.Dist.NoseTailbase = hypot(tempTracking.Tailbase(1,:) - tempTracking.Nose(1,:), tempTracking.Tailbase(2,:) - tempTracking.Nose(2,:)) / Params.px2cm;
    end

    % Head-Tailbase Distance
    if ~isempty(tempTracking.Tailbase) && ~isempty(tempTracking.Head)
        Metrics.Dist.HeadTailbase = hypot(tempTracking.Tailbase(1,:) - tempTracking.Head(1,:), tempTracking.Tailbase(2,:) - tempTracking.Head(2,:)) / Params.px2cm;
    end
    % BetwEars-Tailbase Distance
    if ~isempty(tempTracking.Tailbase) && ~isempty(tempTracking.BetwEars)
        Metrics.Dist.BetwEarsTailbase = hypot(tempTracking.Tailbase(1,:) - tempTracking.BetwEars(1,:), tempTracking.Tailbase(2,:) - tempTracking.BetwEars(2,:)) / Params.px2cm;
    end
    % Head-MidBack Distance
    if ~isempty(tempTracking.MidBack) && ~isempty(tempTracking.Head)
        Metrics.Dist.HeadMidBack = hypot(tempTracking.MidBack(1,:) - tempTracking.Head(1,:), tempTracking.MidBack(2,:) - tempTracking.Head(2,:)) / Params.px2cm;
    end
    % Head-RearBack Distance
    if ~isempty(tempTracking.RearBack) && ~isempty(tempTracking.Head)
        Metrics.Dist.HeadRearBack = hypot(tempTracking.RearBack(1,:) - tempTracking.Head(1,:), tempTracking.RearBack(2,:) - tempTracking.Head(2,:)) / Params.px2cm;
    end
    % Head-LeftLeg Distance
    if ~isempty(tempTracking.Left_Leg) && ~isempty(tempTracking.Head)
        Metrics.Dist.HeadLeftLeg = hypot(tempTracking.Left_Leg(1,:) - tempTracking.Head(1,:), tempTracking.Left_Leg(2,:) - tempTracking.Head(2,:)) / Params.px2cm;
    end
    % Head-RightLeg Distance
    if ~isempty(tempTracking.Right_Leg) && ~isempty(tempTracking.Head)
        Metrics.Dist.HeadRightLeg = hypot(tempTracking.Right_Leg(1,:) - tempTracking.Head(1,:), tempTracking.Right_Leg(2,:) - tempTracking.Head(2,:)) / Params.px2cm;
    end
    % Nose-LeftLeg Distance
    if ~isempty(tempTracking.Left_Leg) && ~isempty(tempTracking.Nose)
        Metrics.Dist.NoseLeftLeg = hypot(tempTracking.Left_Leg(1,:) - tempTracking.Nose(1,:), tempTracking.Left_Leg(2,:) - tempTracking.Nose(2,:)) / Params.px2cm;
    end
    % Nose-RightLeg Distance
    if ~isempty(tempTracking.Right_Leg) && ~isempty(tempTracking.Nose)
        Metrics.Dist.NoseRightLeg = hypot(tempTracking.Right_Leg(1,:) - tempTracking.Nose(1,:), tempTracking.Right_Leg(2,:) - tempTracking.Nose(2,:)) / Params.px2cm;
    end
    % LeftEar-LeftLeg Distance
    if ~isempty(tempTracking.Left_Leg) && ~isempty(tempTracking.Left_Ear)
        Metrics.Dist.LeftEarLeftLeg = hypot(tempTracking.Left_Leg(1,:) - tempTracking.Left_Ear(1,:), tempTracking.Left_Leg(2,:) - tempTracking.Left_Ear(2,:)) / Params.px2cm;
    end
    % RightEar-RightLeg Distance
    if ~isempty(tempTracking.Right_Leg) && ~isempty(tempTracking.Right_Ear)
        Metrics.Dist.RightEarRightLeg = hypot(tempTracking.Right_Leg(1,:) - tempTracking.Right_Ear(1,:), tempTracking.Right_Leg(2,:) - tempTracking.Right_Ear(2,:)) / Params.px2cm;
    end    
    
    %% Calculate Angular Information - Angles are relative to the positive x axis (angle 0 = positive x-axis, pi/-pi = negative x-axis)
    % Calculate Angles in Degrees
    numframes = Params.numFrames;
    
    if ~isempty(tempTracking.BetwEars) && ~isempty(tempTracking.Nose)
        Metrics.degHeadAngle = zeros(1, numframes);
        for i = 1:numframes
            Metrics.degHeadAngle(i) = atan2d(tempTracking.BetwEars(2,i) - tempTracking.Nose(2,i), tempTracking.BetwEars(1,i) - tempTracking.Nose(1,i));
        end
    end

    if ~isempty(tempTracking.BetwEars) && ~isempty(tempTracking.RearBack)
        Metrics.degFullBodyAngle = zeros(1, numframes);
        for i = 1:numframes
            Metrics.degFullBodyAngle(i) = atan2d(tempTracking.RearBack(2,i) - tempTracking.BetwEars(2,i), tempTracking.RearBack(1,i) - tempTracking.BetwEars(1,i));
        end
    end

    if ~isempty(tempTracking.BetwEars) && ~isempty(tempTracking.MidBack)
        Metrics.degFrontBodyAngle = zeros(1, numframes);
        for i = 1:numframes
            Metrics.degFrontBodyAngle(i) = atan2d(tempTracking.MidBack(2,i) - tempTracking.BetwEars(2,i), tempTracking.MidBack(1,i) - tempTracking.BetwEars(1,i));
        end
    end

    if ~isempty(tempTracking.Tailbase) && ~isempty(tempTracking.MidBack)
        Metrics.degRearBodyAngle = zeros(1, numframes);
        for i = 1:numframes
            Metrics.degRearBodyAngle(i) = atan2d(tempTracking.Tailbase(2,i) - tempTracking.MidBack(2,i), tempTracking.Tailbase(1,i) - tempTracking.MidBack(1,i));
        end
    end

    if ~isempty(tempTracking.Tailbase) && ~isempty(tempTracking.Tail)
        Metrics.degTailAngle = zeros(1, numframes);
        for i = 1:numframes
            Metrics.degTailAngle(i) = atan2d(tempTracking.Tailbase(2,i) - tempTracking.Tail(2,i), tempTracking.Tailbase(1,i) - tempTracking.Tail(1,i));
        end
    end

    %% Calculate Angle Differentials  
    % Head Angle
    if isfield(Metrics, 'degHeadAngle')
        ang2 = Metrics.degHeadAngle(2:end);
        ang1 = Metrics.degHeadAngle(1:end-1);
        Metrics.Diff.HeadAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.HeadAngle = [Metrics.Diff.HeadAngle(1), Metrics.Diff.HeadAngle]; %keep same length
        Metrics.Velocity.HeadAngle = Metrics.Diff.HeadAngle * Params.Video.frameRate;  % convert from deg/frame to deg/sec
    end
    
    % Full Body Angle
    if isfield(Metrics, 'degFullBodyAngle')
        ang2 = Metrics.degFullBodyAngle(2:end);
        ang1 = Metrics.degFullBodyAngle(1:end-1);
        Metrics.Diff.FullBodyAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.FullBodyAngle = [Metrics.Diff.FullBodyAngle(1), Metrics.Diff.FullBodyAngle];
        Metrics.Velocity.FullBodyAngle = Metrics.Diff.FullBodyAngle * Params.Video.frameRate;
    end
    
    % Front Body Angle
    if isfield(Metrics, 'degFrontBodyAngle')
        ang2 = Metrics.degFrontBodyAngle(2:end);
        ang1 = Metrics.degFrontBodyAngle(1:end-1);
        Metrics.Diff.FrontBodyAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.FrontBodyAngle = [Metrics.Diff.FrontBodyAngle(1), Metrics.Diff.FrontBodyAngle];
        Metrics.Velocity.FrontBodyAngle = Metrics.Diff.FrontBodyAngle * Params.Video.frameRate;
    end
    
    % Rear Body Angle
    if isfield(Metrics, 'degRearBodyAngle')
        ang2 = Metrics.degRearBodyAngle(2:end);
        ang1 = Metrics.degRearBodyAngle(1:end-1);
        Metrics.Diff.RearBodyAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.RearBodyAngle = [Metrics.Diff.RearBodyAngle(1), Metrics.Diff.RearBodyAngle];
        Metrics.Velocity.RearBodyAngle = Metrics.Diff.RearBodyAngle * Params.Video.frameRate;
    end
    
    % Tail Angle
    if isfield(Metrics, 'degTailAngle')
        ang2 = Metrics.degTailAngle(2:end);
        ang1 = Metrics.degTailAngle(1:end-1);
        Metrics.Diff.TailAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.TailAngle = [Metrics.Diff.TailAngle(1), Metrics.Diff.TailAngle];
        Metrics.Velocity.TailAngle = Metrics.Diff.TailAngle * Params.Video.frameRate;
    end
    
    %% Calculate body part differentials
    % remove empty fields
    fn = fieldnames(tempTracking);
    tf = cellfun(@(c) isempty(tempTracking.(c)), fn);
    tempTracking = rmfield(tempTracking, fn(tf));
    
    % get Tracked field names and convert to cell for easier referencing
    fn = fieldnames(tempTracking);
    trackcell = struct2cell(tempTracking);
    
    % iterate through each tracked part
    for i_part = 1:length(fn)
        Metrics.Diff.(fn{i_part}) = [diff(tempTracking.(fn{i_part})(1,:)); diff(tempTracking.(fn{i_part})(2,:))];
        Metrics.Diff.(fn{i_part}) = Metrics.Diff.(fn{i_part}) * (Params.Video.frameRate / Params.px2cm); % convert from px/frame to cm/sec
        Metrics.Diff.(fn{i_part}) = [Metrics.Diff.(fn{i_part})(:,1), Metrics.Diff.(fn{i_part})]; % to keep length the same
    end
        
    %% Velocity Calculations
    for i_part = 1:length(fn)
        Metrics.Velocity.(fn{i_part}) = hypot(Metrics.Diff.(fn{i_part})(1,:), Metrics.Diff.(fn{i_part})(2,:));
    end

    %% Acceleration Calculations
    for i_part = 1:length(fn)
        Metrics.Acceleration.(fn{i_part}) = diff(Metrics.Velocity.(fn{i_part})) / Params.Video.frameRate;
        Metrics.Acceleration.(fn{i_part}) = [Metrics.Acceleration.(fn{i_part})(:,1), Metrics.Acceleration.(fn{i_part})]; % to keep length the same
    end

    %% Calculate Distance Traveled
    % tries to find suitable part for body location,
    % otherwise averages all parts together to get location
    
    if isfield(tempTracking, 'MidBack')
        locat = tempTracking.MidBack;
    elseif isfield(tempTracking, 'BetwEars')
        locat = tempTracking.BetwEars;
    elseif isfield(tempTracking, 'BetwLegs')
        locat = tempTracking.BetwLegs;
    elseif isfield(tempTracking, 'Head')
        locat = tempTracking.Head;
    elseif isfield(tempTracking, 'Center')
        locat = tempTracking.Center;
    else
        x = [];
        y = [];
        for i_part = 1:length(fn)
            x = [x; trackcell{i_part}(1,:)];
            y = [y; trackcell{i_part}(2,:)];
        end
        locat(1,:) = mean(x,1);
        locat(2,:) = mean(y,1);
    end
    Metrics.Location = locat;

    diff_frame = diff(locat, 1, 2); % Calculate xy differentials (right angle side lengths btwn points)
    dist_frame = hypot(diff_frame(1,:), diff_frame(2,:)); % Pythagorian theorem
    Metrics.Movement.Data = dist_frame * Params.Video.frameRate / Params.px2cm;  % frame by frame movement in cm per sec 
    Metrics.Movement.DataUnits = 'cm per sec';
    Metrics.Movement.DistanceTraveled = [0 cumsum(dist_frame)] / Params.px2cm;  % Cumulative distance traveled per frame
    Metrics.Movement.DistanceUnits = 'cm per frame';
    
    %% Distance from Arena Edge Calculations
    % Collect video parameters and find 9 points to collect distance from
    % (4 edges, 4 corners, and center)
    x_max = Params.Video.frameWidth;
    y_max = Params.Video.frameHeight;

    % Save coordinates to C structure
    C.Center = [x_max/2, y_max/2];
    C.TL_Corner = [0, 0];
    C.BL_Corner = [0, y_max];
    C.TR_Corner = [x_max, 0];
    C.BR_Corner = [x_max, y_max];
    C.L_Edge = [0, y_max/2];
    C.B_Edge = [x_max/2, y_max];
    C.R_Edge = [x_max, y_max/2];
    C.T_Edge = [x_max/2, 0];

    dist_pts = fieldnames(C);
    
    % Calculate distance from each point to animal location (locat)
    for c = 1:length(dist_pts)
        
        this_pt = C.(dist_pts{c});
        % Find difference between xy location and xy coords of this_pt
        dist_to_pt = [locat(1,:) - this_pt(1); locat(2,:) - this_pt(2)];
        
        % Pythagorean theorem; save to Metrics.Dist
        Metrics.Dist.(dist_pts{c})  = hypot(dist_to_pt(1,:), dist_to_pt(2,:));

        clearvars dist_to_pt
    end

    %Tracking.Misc.PreRegistration = Tracking.Smooth;
    Tracking.Smooth = tempTracking;
    
    disp('Tracked point dynamics calculated.')
end

function settingsFolder = localPartLookupFolder(P)
if isfield(P, 'codePath') && ~isempty(P.codePath)
    settingsFolder = P.codePath;
else
    settingsFolder = fileparts(fileparts(mfilename('fullpath')));
end
end
