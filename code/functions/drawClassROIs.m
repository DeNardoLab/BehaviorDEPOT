function P = drawClassROIs(P, frame)
%drawClassROIs Draw classifier-defined ROIs on a full-frame ROI panel.

if ~isfield(P, 'noninteractive')
    P.noninteractive = false;
end

params = P.Params;
behaviorStructs = fieldnames(params);

for behaviorIndex = 1:numel(behaviorStructs)
    behaviorName = behaviorStructs{behaviorIndex};
    behaviorFields = fieldnames(params.(behaviorName));
    labelField = behaviorFields(contains( ...
        behaviorFields, 'ROI_Labels', 'IgnoreCase', true));

    if numel(labelField) ~= 1
        continue
    end

    roiLabels = params.(behaviorName).(labelField{1});
    if isfield(P.Params.(behaviorName), 'ROI_Limits') && ...
            ~isempty(P.Params.(behaviorName).ROI_Limits)
        continue
    elseif P.noninteractive
        error('BehaviorDEPOT:drawClassROIs:MissingClassifierROIConfig', ...
            'Noninteractive runs require P.Params.%s.ROI_Limits for classifier ROI labels.', ...
            behaviorName);
    end

    roiLimits = cell(size(roiLabels));
    for roiIndex = 1:numel(roiLabels)
        confirmed = false;
        while ~confirmed
            [roiLimits{roiIndex}, ~, confirmed] = drawROIWithName( ...
                frame, sprintf('Draw Classifier ROI %d of %d', ...
                roiIndex, numel(roiLabels)), roiLimits(1:roiIndex - 1), ...
                roiLabels{roiIndex}, false);
        end
    end

    P.Params.(behaviorName).ROI_Limits = roiLimits;
end
end
