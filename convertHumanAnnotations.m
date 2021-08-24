% INPUTS:
% 1) table_filename: str/char pointing to MATLAB table file -- 1st Column: StartFrame, 2nd
% Column: StopFrame, 3rd Column (Title = Behavior): Behavior Label

% 2) total_frames: int, optional total number of frames in analyzed video
% NOTE: if total_frames is empty, function will use the video file IF IN
% SAME FOLDER AS INPUT TABLE

% 3) output_filename: str/char, optional (default behavior = hB_[original filename]);
% string specifying name to save file as (exclude filename extension)

% OUTPUT: 
% 1) MAT file containing hBehavior structure with organized behavior information and
% behavior vectors

function convertHumanAnnotations(table_filename, total_frames, output_filename)

% Load Params from MATLAB analysis script OR set total_frames to the total number of video frame
    
    human_labels = load(table_filename);
    
    if ~exist('total_frames')
        % Grab information from video file
        vid_dir = dir('*.avi');
    
        if size(vid_dir, 1) == 0
            vid_dir = dir('*.mp4');
        elseif size(vid_dir, 1) > 1
            vid_search = strcat(table_filename(1:6), '*.avi');
            vid_dir = dir(vid_search);
        end

        video_name = vid_dir.name;
        vid = VideoReader(video_name);
        total_frames = vid.NumFrames;
        frame_rate = vid.FrameRate;
    
        %% Compile Video Data in hBehavior structure

        hBehavior.VideoName = video_name;
        hBehavior.FrameRate = frame_rate;
        hBehavior.TotalFrames = total_frames;

        clearvars vid vid_dir
    else
        hBehavior.TotalFrames = total_frames;
    end

    %% Import Video data as human_labels
    struct_name = string(fieldnames(human_labels));
    data_table = human_labels.(struct_name);
    
    %% Initialize Structures Using User Behavior Labels

    behav_inds = cellstr(data_table.Behavior);
    
    for i = 1:length(behav_inds)
        behav_inds{i} = strrep(behav_inds{i},' ','');
        behav_inds{i} = strrep(behav_inds{i},'-','_');
        behav_inds{i} = strrep(behav_inds{i},'/','');
        behav_inds{i} = strrep(behav_inds{i},'\','');
        behav_inds{i} = strrep(behav_inds{i},'+','');
        behav_inds{i} = strrep(behav_inds{i},'=','');
        behav_inds{i} = strrep(behav_inds{i},'*','');
        behav_inds{i} = strrep(behav_inds{i},'(','_');
        behav_inds{i} = strrep(behav_inds{i},')','');
    end
    
    behav_list = cellstr(unique(behav_inds));
    
    for i = 1:length(behav_list)
        hBehavior.(behav_list{i}).Bouts = [];
        hBehavior.(behav_list{i}).Length = [];
        hBehavior.(behav_list{i}).Count = 0;
        hBehavior.(behav_list{i}).Vector = zeros(total_frames, 1);
    end

    %% Use table inds to access human labels and transform data
    %% Identify Relevant Data
    
    behav_table_inds = zeros(length(behav_inds), 1);
    
    for i = 1:length(behav_inds)
        for j = 1:length(behav_list)
            if strcmp(behav_inds(i), behav_list(j))
                behav_table_inds(i) = j;
            end
        end
    end
    
    %% Grab table name order and save bout data to hBehavior structure
    
    behav_table_names = behav_list(behav_table_inds);
    
    for i = 1:length(behav_table_inds)
        hBehavior.(behav_table_names{i}).Bouts = [hBehavior.(behav_table_names{i}).Bouts; table2array(data_table(i,1:2))];        
    end
    
    %% Populate remaining fields (length, count, vector)
    
    for i = 1:length(behav_list)
       
        hBehavior.(behav_list{i}).Length = hBehavior.(behav_list{i}).Bouts(:,2) - hBehavior.(behav_list{i}).Bouts(:,1);
        hBehavior.(behav_list{i}).Count = length(hBehavior.(behav_list{i}).Bouts);
        
        for j = 1:size(hBehavior.(behav_list{i}).Bouts, 1)
            hBehavior.(behav_list{i}).Vector(hBehavior.(behav_list{i}).Bouts(j,1):hBehavior.(behav_list{i}).Bouts(j,2)) = 1;
        end
    end

    %% Save Results
    
    
    if exist('output_filename')
        output_filename = strcat(output_filename, '.mat')
        save(output_filename, 'hBehavior')
    else
        new_struct_name = strcat('hB_', struct_name);
        new_struct_name = strcat(new_struct_name, '.mat')
        save(new_struct_name, 'hBehavior')
    end
    clear all
end
