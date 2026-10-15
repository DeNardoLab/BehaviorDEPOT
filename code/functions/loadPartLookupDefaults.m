function partMatchInds = loadPartLookupDefaults( ...
        settingsFolder, detectedPartNames, knownPartList)
%loadPartLookupDefaults Load label-based part-registration defaults.

arguments
    settingsFolder (1,:) char
    detectedPartNames cell
    knownPartList cell
end

otherIndex = find(strcmp(knownPartList, 'Other'), 1);
if isempty(otherIndex)
    error('BehaviorDEPOT:loadPartLookupDefaults:MissingOtherPart', ...
        'Known-part definitions must include Other.');
end

partMatchInds = repmat(otherIndex, 1, numel(detectedPartNames));
lookupPath = fullfile(settingsFolder, 'part_lookup.mat');
if ~isfile(lookupPath)
    return
end

try
    savedData = load(lookupPath, 'partLookup');
    partLookup = savedData.partLookup;
    storedDetectedNames = partLookup.DetectedPartNames;
    storedKnownNames = partLookup.KnownPartNames;
    if ~(iscellstr(storedDetectedNames) || isstring(storedDetectedNames)) || ...
            ~(iscellstr(storedKnownNames) || isstring(storedKnownNames)) || ...
            numel(storedDetectedNames) ~= numel(storedKnownNames)
        return
    end
    storedDetectedNames = cellstr(storedDetectedNames);
    storedKnownNames = cellstr(storedKnownNames);
catch
    return
end

usedKnownParts = false(1, numel(knownPartList));
for partIndex = 1:numel(detectedPartNames)
    storedIndex = find(strcmpi(storedDetectedNames, detectedPartNames{partIndex}), 1);
    if isempty(storedIndex)
        continue
    end

    knownIndex = find(strcmp(knownPartList, storedKnownNames{storedIndex}), 1);
    if isempty(knownIndex) || ...
            (knownIndex ~= otherIndex && usedKnownParts(knownIndex))
        continue
    end

    partMatchInds(partIndex) = knownIndex;
    if knownIndex ~= otherIndex
        usedKnownParts(knownIndex) = true;
    end
end
end
