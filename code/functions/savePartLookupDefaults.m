function savePartLookupDefaults(settingsFolder, detectedPartNames, ...
        partMatchInds, knownPartList)
%savePartLookupDefaults Save a confirmed label-based part registration.

arguments
    settingsFolder (1,:) char
    detectedPartNames cell
    partMatchInds {mustBeNumeric, mustBeVector}
    knownPartList cell
end

partMatchInds = validatePartMatchInds( ...
    partMatchInds, knownPartList, numel(detectedPartNames));
if ~isfolder(settingsFolder)
    return
end

partLookup = struct( ...
    'DetectedPartNames', {detectedPartNames(:)'}, ...
    'KnownPartNames', {knownPartList(partMatchInds)});
save(fullfile(settingsFolder, 'part_lookup.mat'), 'partLookup');
end
