%% getFiles_batch()
% Helper function for finding input files when running batch analysis

function P = getFiles_batch(P)

%% EXTRACT VIDEO DATA & FRAMES

has_video_files = isfield(P, 'video_file') && ~isempty(P.video_file);
has_tracking_files = isfield(P, 'tracking_file') && ~isempty(P.tracking_file);

if ~(has_video_files && has_tracking_files) && ...
        isfield(P, 'noninteractive') && P.noninteractive && ...
        (~isfield(P, 'video_directory') || isempty(P.video_directory))
    error('BehaviorDEPOT:getFilesBatch:MissingInputs', ...
        'Batch noninteractive runs require P.video_directory or paired P.video_file/P.tracking_file lists.');
end

manifest = buildBatchSessionManifest(P);
P.batchSessionManifest = manifest;
P.video_folder_list = reshape([manifest.SessionName], 1, []);
P.video_file = {manifest.VideoFile};
P.tracking_file = {manifest.TrackingFile};
P.cueFile = {manifest.CueFiles};

if isfield(P, 'video_directory') && ~isempty(P.video_directory)
    P.basedir = P.video_directory;
elseif ~isfield(P, 'basedir') || isempty(P.basedir)
    [P.basedir, ~, ~] = fileparts(P.video_file{1});
end
end
