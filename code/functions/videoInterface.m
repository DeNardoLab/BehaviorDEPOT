function [Frame, P] = videoInterface(video_name, P)

% warn user this may take a while
disp('Loading video. May take some time depending on size of video.')

% Create video object (.avi or .mp4)
vid = VideoReader(video_name);

% Save info to P
P.Video.name = vid.Name;
P.Video.length = vid.Duration;
P.Video.frameRate = vid.FrameRate;
P.Video.totalFrames = vid.NumFrames;
P.Video.frameWidth = vid.Width;
P.Video.frameHeight = vid.Height;
disp('Video Loaded');
P.Video.location = video_name;

% Collect 5 random frames
frame_idx = randi(vid.numFrame, 1, 5);  % take random frame to verify tracking

Frame = struct();

for i = frame_idx
    Frame.(['n' int2str(i)]) = read(vid, i); 
end

end