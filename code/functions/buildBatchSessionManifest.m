function manifest = buildBatchSessionManifest(P)
% buildBatchSessionManifest Build validated batch session file manifest.
%
% OUTPUT:
% manifest: struct array with SessionName, SessionFolder, VideoFile,
% TrackingFile, and CueFiles. CueFiles is always a cell array of paths.

has_video_files = isfield(P, 'video_file') && ~isempty(P.video_file);
has_tracking_files = isfield(P, 'tracking_file') && ~isempty(P.tracking_file);

if has_video_files && has_tracking_files
    manifest = buildExplicitManifest(P);
    return
end

if ~isfield(P, 'video_directory') || isempty(P.video_directory)
    error('BehaviorDEPOT:getFilesBatch:MissingInputs', ...
        'Batch runs require P.video_directory or paired P.video_file/P.tracking_file lists.');
end

if ~isfield(P, 'video_folder_list') || isempty(P.video_folder_list)
    error('BehaviorDEPOT:getFilesBatch:MissingInputs', ...
        'Batch folder discovery requires P.video_folder_list.');
end

video_folder_list = reshape(string(P.video_folder_list), 1, []);
manifest = initializeManifest(numel(video_folder_list));

for j = 1:numel(video_folder_list)
    session_name = video_folder_list(j);
    session_folder = fullfile(P.video_directory, session_name);
    session_files = dir(session_folder);
    session_files = session_files(~[session_files.isdir]);

    video_candidates = selectFileCandidates(session_files, {'.avi', '.mp4'});
    if isempty(video_candidates)
        error('BehaviorDEPOT:getFilesBatch:MissingVideo', ...
            'No .avi or .mp4 video file found in %s.', session_folder);
    elseif numel(video_candidates) > 1
        error('BehaviorDEPOT:getFilesBatch:AmbiguousVideo', ...
            'Expected one video file in %s, found: %s', ...
            session_folder, strjoin({video_candidates.name}, ', '));
    end

    video_file = fullfile(session_folder, video_candidates.name);
    tracking_candidates = findTrackingCandidates(P, session_files, video_file);
    if isempty(tracking_candidates)
        error('BehaviorDEPOT:getFilesBatch:MissingTracking', ...
            'No tracking file found in %s.', session_folder);
    elseif numel(tracking_candidates) > 1
        error('BehaviorDEPOT:getFilesBatch:AmbiguousTracking', ...
            'Expected one tracking file in %s, found: %s', ...
            session_folder, strjoin({tracking_candidates.name}, ', '));
    end

    cue_candidates = selectCueCsvFiles(session_files);
    manifest(j).SessionName = session_name;
    manifest(j).SessionFolder = char(session_folder);
    manifest(j).VideoFile = char(video_file);
    manifest(j).TrackingFile = fullfile(session_folder, tracking_candidates.name);
    manifest(j).CueFiles = makeFullFileCell(cue_candidates);
end
end

function manifest = buildExplicitManifest(P)
video_files = normalizeFileList(P.video_file);
tracking_files = normalizeFileList(P.tracking_file);

if numel(video_files) ~= numel(tracking_files)
    error('BehaviorDEPOT:getFilesBatch:FileCountMismatch', ...
        'P.video_file and P.tracking_file must contain the same number of files.');
end

if isfield(P, 'video_folder_list') && ~isempty(P.video_folder_list)
    session_names = reshape(string(P.video_folder_list), 1, []);
    if numel(session_names) ~= numel(video_files)
        error('BehaviorDEPOT:getFilesBatch:FileCountMismatch', ...
            'P.video_folder_list must match P.video_file and P.tracking_file length.');
    end
else
    session_names = strings(1, numel(video_files));
    for j = 1:numel(video_files)
        [~, video_name, ~] = fileparts(video_files{j});
        session_names(j) = string(video_name);
    end
end

cue_files = explicitCueFiles(P, numel(video_files));
manifest = initializeManifest(numel(video_files));

for j = 1:numel(video_files)
    [session_folder, ~, ~] = fileparts(video_files{j});
    manifest(j).SessionName = session_names(j);
    manifest(j).SessionFolder = session_folder;
    manifest(j).VideoFile = video_files{j};
    manifest(j).TrackingFile = tracking_files{j};
    manifest(j).CueFiles = cue_files{j};
end
end

function manifest = initializeManifest(num_sessions)
manifest = repmat(struct( ...
    'SessionName', "", ...
    'SessionFolder', '', ...
    'VideoFile', '', ...
    'TrackingFile', '', ...
    'CueFiles', {{}}), 1, num_sessions);
end

function file_list = normalizeFileList(files)
if ischar(files) || isstring(files)
    file_list = cellstr(string(files));
else
    file_list = files;
end
file_list = reshape(file_list, 1, []);
end

function cue_files = explicitCueFiles(P, num_sessions)
cue_files = repmat({{}}, 1, num_sessions);

if isfield(P, 'cueFiles') && ~isempty(P.cueFiles)
    raw_cue_files = P.cueFiles;
elseif isfield(P, 'cueFile') && ~isempty(P.cueFile)
    raw_cue_files = P.cueFile;
else
    return
end

if num_sessions == 1
    cue_files{1} = normalizeCueFiles(raw_cue_files);
elseif iscell(raw_cue_files) && numel(raw_cue_files) == num_sessions
    for j = 1:num_sessions
        cue_files{j} = normalizeCueFiles(raw_cue_files{j});
    end
elseif isstring(raw_cue_files) && numel(raw_cue_files) == num_sessions
    for j = 1:num_sessions
        cue_files{j} = normalizeCueFiles(raw_cue_files(j));
    end
else
    error('BehaviorDEPOT:getFilesBatch:FileCountMismatch', ...
        'Batch cue files must be omitted, supplied for one explicit session, or match the number of sessions.');
end
end

function cue_files = normalizeCueFiles(files)
if isempty(files)
    cue_files = {};
elseif ischar(files) || isstring(files)
    cue_files = cellstr(string(files));
elseif iscell(files)
    cue_files = reshape(files, 1, []);
else
    error('BehaviorDEPOT:getFilesBatch:InvalidCueFiles', ...
        'Cue files must be char, string, or cell arrays of file paths.');
end
end

function candidates = selectFileCandidates(files, extensions)
if isempty(files)
    candidates = files;
    return
end

file_names = {files.name};
[~, ~, file_exts] = cellfun(@fileparts, file_names, 'UniformOutput', false);
is_match = ismember(lower(file_exts), lower(extensions));
candidates = files(is_match);
end

function tracking_candidates = findTrackingCandidates(P, session_files, video_file)
tracking_type = P.tracking_type;

if contains(tracking_type, 'h5')
    tracking_candidates = selectFileCandidates(session_files, {'.h5'});
elseif contains(tracking_type, 'csv')
    csv_candidates = selectFileCandidates(session_files, {'.csv'});
    csv_names = {csv_candidates.name};
    non_tracking_csv = contains(csv_names, 'cue', 'IgnoreCase', true) | ...
        contains(csv_names, 'annotation', 'IgnoreCase', true) | ...
        contains(csv_names, 'manual', 'IgnoreCase', true);
    csv_candidates = csv_candidates(~non_tracking_csv);

    [~, video_name] = fileparts(video_file);
    tracking_names = {csv_candidates.name};
    video_name_stem = regexprep(video_name, '_?video$', '', 'ignorecase');
    name_matches = contains(tracking_names, video_name) | ...
        contains(tracking_names, video_name_stem) | ...
        contains(tracking_names, 'tracking', 'IgnoreCase', true);

    if any(name_matches)
        tracking_candidates = csv_candidates(name_matches);
    else
        tracking_candidates = csv_candidates;
    end
else
    error('BehaviorDEPOT:getFilesBatch:UnsupportedTrackingType', ...
        'Unsupported tracking type: %s', tracking_type);
end
end

function cue_files = selectCueCsvFiles(files)
csv_candidates = selectFileCandidates(files, {'.csv'});
csv_names = {csv_candidates.name};
cue_files = csv_candidates(contains(csv_names, 'cue', 'IgnoreCase', true));
end

function files = makeFullFileCell(file_structs)
files = cell(1, numel(file_structs));
for i = 1:numel(file_structs)
    files{i} = fullfile(file_structs(i).folder, file_structs(i).name);
end
end
