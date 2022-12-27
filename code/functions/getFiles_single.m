%% getFiles_single()

function P = getFiles_single(P)

P.script_dir = pwd; % directory with script files (avoids requiring changes to path)
disp('Select tracking file'); % point to folder for analysis
if ~ispc
    menu('Select tracking file', 'OK')
end
[ft, pt] = uigetfile('*.*','Select tracking file');
cd(pt)
disp('Select video file'); % point to folder for analysis
if ~ispc
    menu('Select video file', 'OK')
end
[fv, pv] = uigetfile('*.*','Select video file');

% Save relevant info to P structure
P.basedir = pt;
P.tracking_file = {[pt ft]};
P.video_file = {[pv fv]};
P.video_folder_list = string(fv);

end