function partMatchInds = validatePartMatchInds(partMatchInds, knownPartList, numDetectedParts)
%validatePartMatchInds Validate detected-to-known part assignments.

arguments
    partMatchInds {mustBeNumeric, mustBeVector}
    knownPartList cell
    numDetectedParts (1,1) double {mustBeInteger, mustBeNonnegative}
end

partMatchInds = reshape(partMatchInds, 1, []);
if numel(partMatchInds) ~= numDetectedParts
    error('BehaviorDEPOT:calculateMetrics:PartMatchCountMismatch', ...
        'Part registration must contain one assignment for each tracked part.');
end

if any(partMatchInds < 1) || any(partMatchInds > numel(knownPartList)) || ...
        any(partMatchInds ~= floor(partMatchInds))
    error('BehaviorDEPOT:calculateMetrics:InvalidPartMatch', ...
        'Part registration contains an invalid known-part selection.');
end

otherIndex = find(strcmp(knownPartList, 'Other'), 1);
if isempty(otherIndex)
    error('BehaviorDEPOT:calculateMetrics:MissingOtherPart', ...
        'Known-part definitions must include Other.');
end

namedPartInds = partMatchInds(partMatchInds ~= otherIndex);
if numel(unique(namedPartInds)) ~= numel(namedPartInds)
    error('BehaviorDEPOT:calculateMetrics:DuplicateKnownPart', ...
        'Each named known part may be assigned to only one detected part.');
end
end
