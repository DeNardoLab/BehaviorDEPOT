%% getFiles_single()

function P = getFiles_single(P)

P.script_dir = pwd; % directory with script files (avoids requiring changes to path)

has_tracking_file = isfield(P, 'tracking_file') && ~isempty(P.tracking_file);
has_video_file = isfield(P, 'video_file') && ~isempty(P.video_file);

if has_tracking_file && has_video_file
    if ischar(P.tracking_file) || isstring(P.tracking_file)
        P.tracking_file = cellstr(string(P.tracking_file));
    end
    if ischar(P.video_file) || isstring(P.video_file)
        P.video_file = cellstr(string(P.video_file));
    end
    [P.basedir, ~, ~] = fileparts(P.tracking_file{1});
    [~, video_name] = fileparts(P.video_file{1});
    P.video_folder_list = string(video_name);
    return
elseif isfield(P, 'noninteractive') && P.noninteractive
    error('BehaviorDEPOT:getFilesSingle:MissingFiles', ...
        'Single-session noninteractive runs require P.tracking_file and P.video_file.');
end

disp('Select tracking file'); % point to folder for analysis
if ~ispc
    menu('Select tracking file', 'OK')
end
[ft, pt] = uigetfile('*.*','Select tracking file');
disp('Select video file'); % point to folder for analysis
if ~ispc
    menu('Select video file', 'OK')
end
[fv, pv] = uigetfile(fullfile(pt, '*.*'),'Select video file');

% Save relevant info to P structure
P.basedir = pt;
P.tracking_file = {fullfile(pt, ft)};
P.video_file = {fullfile(pv, fv)};
[~, video_name] = fileparts(fv);
P.video_folder_list = string(video_name);

end
