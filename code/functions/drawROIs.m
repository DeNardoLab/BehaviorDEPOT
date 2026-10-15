function P = drawROIs(Frame, P)
%drawROIs Draw and name user-defined ROIs on a full-frame ROI panel.

if ~isfield(P, 'noninteractive')
    P.noninteractive = false;
end

frameIds = fieldnames(Frame);
frame = Frame.(frameIds{randi(numel(frameIds))});

if ~P.do_ROI
    return
end

hasSavedROIs = isfield(P, 'roi_limits') && ~isempty(P.roi_limits) && ...
    isfield(P, 'roi_names') && ~isempty(P.roi_names);

% If there are already saved ROIs, then turn on reuse and return
if hasSavedROIs   
    if P.batchSession && P.reuse_roi_limits
        P.reuse_roi_limits = true;
        P.reuse_roi_names = true;
        return
    end
    
elseif P.noninteractive
    error('BehaviorDEPOT:drawROIs:MissingROIConfig', ...
        'Noninteractive runs with P.do_ROI require P.roi_limits and P.roi_names.');
end

% Default start if there are no saved ROIs
if ~P.reuse_roi_limits
    roiLimits = cell(1, P.number_ROIs);
    roiNames = cell(1, P.number_ROIs);

    if P.reuse_roi_names
        roiNames = P.roi_names;
    end

    for roiIndex = 1:P.number_ROIs
        confirmed = false;
        while ~confirmed
            [roiLimits{roiIndex}, roiNames{roiIndex}, confirmed] = drawROIWithName( ...
                frame, sprintf('Draw User ROI %d of %d', roiIndex, P.number_ROIs), ...
                roiLimits(1:roiIndex - 1), roiNames{roiIndex}, true);
        end
    end

    % Save drawn ROIs to P structure
    if ~P.reuse_roi_names
        P.roi_names = roiNames;
    end
    P.roi_limits = roiLimits;

    % Prompt user for reuse preferences
    if P.batchSession && ~hasSavedROIs
        reuseROI = questdlg( ...
            'Re-use ROIs for other batched process files?', 'ROI Options', ...
            'Names & Limits', 'Names Only', 'No', 'No');
        if isequal(reuseROI, 'No')
            P.reuse_roi_limits = false;
            P.reuse_roi_names = false;
        elseif isequal(reuseROI, 'Names & Limits')
            P.reuse_roi_limits = true;
            P.reuse_roi_names = true;
        elseif isequal(reuseROI, 'Names Only')
            P.reuse_roi_limits = false;
            P.reuse_roi_names = true;
        end
    end
end
end
