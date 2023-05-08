%% getFiles_batch()
% Helper function for finding input files when running batch analysis

function P = getFiles_batch(P)

%% EXTRACT VIDEO DATA & FRAMES

P.video_file = cell(1, size(P.video_folder_list, 2));
P.tracking_file = cell(1, size(P.video_folder_list, 2));

for j = 1:size(P.video_folder_list, 2)

    vid_folder_name = P.video_folder_list(j);
    video_folder_path = strcat(P.video_directory, addSlash(), vid_folder_name);
    
    cd(video_folder_path) %Folder with data files
    
    if size(dir('*.avi'), 1) == 1
        vid_extension = '*.avi';
    elseif size(dir('*.mp4'), 1) == 1
        vid_extension = '*.mp4';
    else
        disp('ERROR: Video Not Recognized. Ensure a single video file (avi/mp4) is in each session folder in the batch directory')
        return
    end
    
    % Collect video name from vid_extension
    V = dir(vid_extension);
    
    try
        video_name = V.name;
    catch ME
        if (strcmp(ME.identifier,'MATLAB:needMoreRhsOutputs'))
            msg = 'Error loading video'; % common error is to not have correct video file type selected
            causeException = MException('MATLAB:needMoreRhsOutputs',msg);
            ME = addCause(ME,causeException);
        end
        rethrow(ME)
    end
    
    clear V
    
    % Store full video path + file
    full_vid_path = strcat(video_folder_path,addSlash(),video_name);
    
    %% EXTRACT/REGISTER TRACKING FILE

    tracking_type = P.tracking_type;

    h5_search = dir('*.h5');
    csv_search = dir('*.csv');
    
    if contains(tracking_type, 'h5')
        tracking_file = h5_search.name;
    elseif contains(tracking_type, 'csv')
        if length(csv_search) > 1  % differentiate cue and tracking csv files
            [~,vid_name] = fileparts(full_vid_path);
            for s = 1:length(csv_search)
                if contains(csv_search(s).name, vid_name) && ~contains(csv_search(s).name, 'cue', 'IgnoreCase', true)
                    trackfile = s;
                end
            end
        else
            trackfile = 1;
        end

        tracking_file = csv_search(trackfile).name;
    end

    P.video_file{j} = full_vid_path;
    P.tracking_file{j} = strcat(video_folder_path,addSlash(),tracking_file);
end

P.basedir = P.video_directory;
end