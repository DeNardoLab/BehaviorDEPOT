function [frame, frame1, frame_idx, P] = videoInterface(video_name, P)

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
    
    % load frames
    frame_idx = randi(vid.numFrame,1);  % take random frame to verify tracking
    frame = read(vid, frame_idx);
    frame1 = read(vid, 1);   % take first frame for trajectory plotting 
    
    % Draw ROI
    P.roi_limits = [];
    roi_name = [];
    if P.do_ROI
        for r = 1:P.number_ROIs
            disp(['Select ROI # ' num2str(r)]);
            imshow(frame)
            
            if r > 1
               hold on;
               for nroi = 1:(r-1)
                   plot(polyshape(P.roi_limits{nroi}), 'FaceAlpha', 0.25)
               end
            end
            
            title(['Select ROI # ' num2str(r)]);
            roi = drawpolygon;
            P.roi_limits{r} = roi.Position;
            close;

            prompt = {'Assign name to ROI'};  % give name to ROI
            dlgtitle = 'Input';
            dims = [1 40];
            definput = {''};
            name = inputdlg(prompt,dlgtitle,dims,definput);
            name = cleanText(name);  % removes non alphanumeric chars
            roi_name{r} = char(name);
        end
    end
    
    P.roi_name = roi_name;

end