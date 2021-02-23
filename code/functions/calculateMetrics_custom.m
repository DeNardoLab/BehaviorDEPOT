%calculateMetrics

%INPUT: Tracking structure
%OUTPUT: Metrics structure

%FUNCTION: Calculate useful metrics for animal behavior classification
%using the smoothed tracking data from Tracking

function [Metrics, Tracking, Params, P] = calculateMetrics_custom(Tracking, Params, P)
    
    %% Register tracked parts with custom names to known body parts
    
    % part_list contains list of tracking points of interest. Additional
    % points can be added.
    % part_lookup(i) refers to the i_th field in Tracking.Smooth, and
    % returns the ordered assignment from part_list
    % example:  if part_list(8), 'Tailbase', is tracked in the 4th field of
    % Tracking.Smooth, part_lookup(4) returns 8
    
    part_names = Params.part_names;
    part_list = {'Nose', 'Left_Ear', 'Right_Ear', 'BetwEars', 'Head', 'Neck', 'MidBack', 'RearBack', 'Left_Leg', 'Right_Leg', 'BetwLegs', 'Tailbase', 'Tail', 'Implant_Base', 'Implant', 'Other'};

    % on first run in batch session, prompt user to register body parts,
    % then ask if want to save that list for future use
    if isempty(P.part_save) | isequal(P.part_save, "No")
        part_lookup = [];
        disp('Select corresponding body part for tracked point labels. Select "Other" if part is not listed')
        for i_part = 1:length(Params.part_names)
            this_part = Params.part_names{i_part};
            [indx,~] = listdlg('PromptString',{'Select matching body part for:  ', this_part, 'Select "Other" if part not listed'},'SelectionMode','single','ListString',part_list);
            part_lookup = [part_lookup, indx];
        end 
    else
        part_lookup = P.part_lookup;
    end

    if isempty(P.part_save)
         dlgTitle    = 'Part list save';
         dlgQuestion = 'Do you wish to use the same part list for all batched analyses?';
         P.part_save = questdlg(dlgQuestion,dlgTitle,"Yes","No", "Yes");
         
         if P.part_save == "Yes"
             P.part_lookup = part_lookup;
         else
             P.part_lookup = [];
         end
    end
             
             
        
        
    % create new struct to refer to tracked parts with known names. 
    % 'Other' tracked parts are assigned their original name 
    % assigns untracked parts from part_list as empty
    trackcell = struct2cell(Tracking.Smooth);
    Track2 = struct;
    for i = 1:length(part_list)
        if ~isempty(find(part_lookup == i))
            if string(part_list{i}) ~= "Other" 
                Track2.(part_list{i}) = trackcell{(find(part_lookup == i))};
            else
                Track2.(part_names{i}) = trackcell{(find(part_lookup == i))};
            end
        else
            Track2.(part_list{i}) = [];
        end
    end
    Track2 = rmfield(Track2,'Other');

    %% Calculate metrics based on body parts
    % Calculate point between ears
    if ~isempty(Track2.Left_Ear) && ~isempty(Track2.Right_Ear)
            Track2.BetwEars(1,:) = (Track2.Left_Ear(1,:) + Track2.Right_Ear(1,:))/2;
            Track2.BetwEars(2,:) = (Track2.Left_Ear(2,:) + Track2.Right_Ear(2,:))/2;
    end
    
    % Calculate point between legs
    if ~isempty(Track2.Left_Leg) && ~isempty(Track2.Right_Leg)
            Track2.BetwLegs(1,:) = (Track2.Left_Leg(1,:) + Track2.Right_Leg(1,:))/2;
            Track2.BetwLegs(2,:) = (Track2.Left_Leg(2,:) + Track2.Right_Leg(2,:))/2;
    end

    % Calculate Head position from LeftEar, RightEar, optionally Nose
    if isempty(Track2.Head)
        if ~isempty(Track2.Left_Ear) && ~isempty(Track2.Right_Ear) && ~isempty(Track2.Nose)
            temp_x = nanmean([Track2.Nose(1,:); Track2.Left_Ear(1,:); Track2.Right_Ear(1,:)]);
            temp_y = nanmean([Track2.Nose(2,:); Track2.Left_Ear(2,:); Track2.Right_Ear(2,:)]);
            Track2.Head = [temp_x; temp_y];
        else
            Track2.Head = Track2.BetwEars;
        end
    end
    
    % Calculate MidBack
    if isempty(Track2.MidBack) && ~isempty(Track2.BetwEars) && ~isempty(Track2.BetwLegs)
            Track2.MidBack(1,:) = (Track2.BetwEars(1,:) + Track2.BetwLegs(1,:))/2;
            Track2.MidBack(2,:) = (Track2.BetwEars(2,:) + Track2.BetwLegs(2,:))/2;
    elseif isempty(Track2.MidBack) && ~isempty(Track2.BetwEars) && ~isempty(Track2.Tailbase)
            Track2.MidBack(1,:) = (Track2.BetwEars(1,:) + Track2.Tailbase(1,:))/2;
            Track2.MidBack(2,:) = (Track2.BetwEars(2,:) + Track2.Tailbase(2,:))/2;
    end
        
        
    % Calculate BetwShoulders position from LeftEar, RightEar, and MidBack
    if ~isempty(Track2.Left_Ear) && ~isempty(Track2.Right_Ear) && ~isempty(Track2.MidBack)
        temp_x = nanmean([Track2.Left_Ear(1,:); Track2.Right_Ear(1,:); Track2.MidBack(1,:)]);
        temp_y = nanmean([Track2.Left_Ear(2,:); Track2.Right_Ear(2,:); Track2.MidBack(2,:)]);
        Track2.BetwShoulders = [temp_x; temp_y];
    end
    
    % Calculate RearBack position from LeftLeg, RightLeg, and Tailbase
    if  ~isempty(Track2.Left_Leg) && ~isempty(Track2.Right_Leg) && ~isempty(Track2.Tailbase)
        temp_x = nanmean([Track2.Left_Leg(1,:); Track2.Right_Leg(1,:); Track2.Tailbase(1,:)]);
        temp_y = nanmean([Track2.Left_Leg(2,:); Track2.Right_Leg(2,:); Track2.Tailbase(2,:)]);
        Track2.RearBack = [temp_x; temp_y];
    end
    
    %% Calculate Angular Information
    % Angles are relative to the positive x axis (angle 0 = positive x-axis, pi/-pi = negative x-axis)

    % Calculate angles in degrees
    numframes = length(temp_x);
    for i = 1:numframes
        try 
            Metrics.degHeadAngle(i) = atan2d(Track2.BetwEars(2,i) - Track2.Nose(2,i), Track2.BetwEars(1,i) - Track2.Nose(1,i));
        end
        try
            Metrics.degFullBodyAngle(i) = atan2d(Track2.RearBack(2,i) - Track2.BetwEars(2,i), Track2.RearBack(1,i) - Track2.BetwEars(1,i));
        end
        try
            Metrics.degFrontBodyAngle(i) = atan2d(Track2.MidBack(2,i) - Track2.BetwEars(2,i), Track2.MidBack(1,i) - Track2.BetwEars(1,i));
        end
        try
            Metrics.degRearBodyAngle(i) = atan2d(Track2.Tailbase(2,i) - Track2.MidBack(2,i), Track2.Tailbase(1,i) - Track2.MidBack(1,i));
        end
        try
            Metrics.degTailAngle(i) = atan2d(Track2.Tailbase(2,i) - Track2.Tail(2,i), Track2.Tailbase(1,i) - Track2.Tail(1,i));
        end
    end

    %% Calculate Angle Differentials  

    % Head Angle
    if isfield(Metrics,'degHeadAngle')
        ang2 = Metrics.degHeadAngle(2:end);
        ang1 = Metrics.degHeadAngle(1:end-1);
        Metrics.Diff.HeadAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.HeadAngle = [Metrics.Diff.HeadAngle(1), Metrics.Diff.HeadAngle]; %keep same length
        Metrics.Diff.HeadAngle = Metrics.Diff.HeadAngle * Params.Video.frameRate;  % convert from deg/frame to deg/sec
    end
    
    % Full Body Angle
    if isfield(Metrics, 'degFullBodyAngle')
        ang2 = Metrics.degFullBodyAngle(2:end);
        ang1 = Metrics.degFullBodyAngle(1:end-1);
        Metrics.Diff.FullBodyAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.FullBodyAngle = [Metrics.Diff.FullBodyAngle(1), Metrics.Diff.FullBodyAngle];
        Metrics.Diff.FullBodyAngle = Metrics.Diff.FullBodyAngle * Params.Video.frameRate;
    end
    
    % Front Body Angle
    if isfield(Metrics, 'degFrontBodyAngle')
        ang2 = Metrics.degFrontBodyAngle(2:end);
        ang1 = Metrics.degFrontBodyAngle(1:end-1);
        Metrics.Diff.FrontBodyAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.FrontBodyAngle = [Metrics.Diff.FrontBodyAngle(1), Metrics.Diff.FrontBodyAngle];
        Metrics.Diff.FrontBodyAngle = Metrics.Diff.FrontBodyAngle * Params.Video.frameRate;
    end
    
    % Tail Angle
    if isfield(Metrics, 'degTailAngle')
        ang2 = Metrics.degTailAngle(2:end);
        ang1 = Metrics.degTailAngle(1:end-1);
        Metrics.Diff.TailAngle = mod(ang2 - ang1 + 180, 360) - 180; % use modulo for negative angle crossovers
        Metrics.Diff.TailAngle = [Metrics.Diff.TailAngle(1), Metrics.Diff.TailAngle];
        Metrics.Diff.TailAngle = Metrics.Diff.TailAngle * Params.Video.frameRate;
    end
    
    %% Calculate body part differentials

    % remove empty fields
    fn = fieldnames(Track2);
    tf = cellfun(@(c) isempty(Track2.(c)), fn);
    Track2 = rmfield(Track2, fn(tf));
    
    % get Tracked field names and convert to cell for easier referencing
    fn = fieldnames(Track2);
    trackcell = struct2cell(Track2);
    
    % iterate through each tracked part
    for i_part = 1:length(fn)
        Metrics.Diff.(fn{i_part}) = [diff(Track2.(fn{i_part})(1,:)); diff(Track2.(fn{i_part})(2,:))];
        Metrics.Diff.(fn{i_part}) = Metrics.Diff.(fn{i_part}) * (Params.Video.frameRate / Params.px2cm); % convert from px/frame to  cm/sec
        Metrics.Diff.(fn{i_part}) = [Metrics.Diff.(fn{i_part})(:,1), Metrics.Diff.(fn{i_part})]; % to keep length the same
    end
        
    %% Velocity Calculations
    
    for i_part = 1:length(fn)
        for i = 1:numframes
            Metrics.Velocity.(fn{i_part})(i) = sqrt(Metrics.Diff.(fn{i_part})(1,i)^2 + Metrics.Diff.(fn{i_part})(2,i)^2); % find hypotenuse
        end
    end


    %% Acceleration Calculations
    for i_part = 1:length(fn)
        Metrics.Acceleration.(fn{i_part}) = diff(Metrics.Velocity.(fn{i_part}));
        Metrics.Acceleration.(fn{i_part}) = [Metrics.Acceleration.(fn{i_part})(:,1), Metrics.Acceleration.(fn{i_part})]; % to keep length the same
        %LOOK INTO ACCERLATION UNIT ACCURACY
    end
  
    %% calculate distance travelled
    % tries to find suitable part for body location,
    % otherwise averages all parts together to get location
    if isfield(Track2, 'MidBack')
        loc = Track2.MidBack;
    elseif isfield(Track2, 'RearBack')
        loc = Track2.RearBack;
    elseif isfield(Track2, 'BetwLegs')
        loc = Track2.BetwLegs;
    elseif isfield(Track2, 'Head')
        loc = Track2.Head;
    else
        x = [];
        y = [];
        for i_part = 1:length(fn)
            x = [x; trackcell{i_part}(1,:)];
            y = [y; trackcell{i_part}(2,:)];
        end
        loc(1,:) = mean(x,1);
        loc(2,:) = mean(y,1);
    end
    Metrics.Location = loc;
    
    loc = loc';
    diff_frame = [diff(loc,1); loc(end,:)-loc(1,:)];
    dist_frame = sqrt(sum(diff_frame .* diff_frame,2));
    Metrics.Movement_cmpersec = dist_frame * Params.Video.frameRate / Params.px2cm;  % frame by frame movement in cm per sec  
    Metrics.DistanceTravelled_cm = sum(dist_frame) / Params.px2cm;  % total movment in cm
    
    Tracking.Smooth_Original = Tracking.Smooth;
    Tracking.Smooth = Track2;
    
    disp('Tracked point dynamics calculated.')
    close;
end