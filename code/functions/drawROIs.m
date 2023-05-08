function P = drawROIs(Frame, P)

% Collect video frame to display
frame_ids = fieldnames(Frame);
frame = Frame.(frame_ids{randi(5,1)});

% Draw ROI
roi_limits = [];
roi_name = [];    

if P.do_ROI
    if ~isfield(P, 'reuse_roi_limits')
        for r = 1:P.number_ROIs
            repeat = true;
            while repeat
                disp(['Select ROI # ' num2str(r)]);
                imshow(frame)
                
                % Plot previously drawn ROIs
                if r > 1
                   hold on;
                   for nroi = 1:(r-1)
                       plot(polyshape(P.roi_limits{nroi}), 'FaceAlpha', 0.25)
                   end
                end
                
                title(['Select ROI # ' num2str(r)]);

                % Draw roi limits
                roi = drawpolygon;
                roi_limits{r} = roi.Position;
                close;

                prompt = {'Assign name to ROI (or press cancel to redraw ROI)'};  % give name to ROI
                dlgtitle = 'Input';
                dims = [1 60];
                name = inputdlg(prompt,dlgtitle,dims);
                if isempty(name)
                    repeat = true;
                else
                    repeat = false;
                end
            end

            name = cleanText(name);  % removes non alphanumeric chars
            roi_name{r} = char(name);
        end
        
        P.roi_names = roi_name;
        P.roi_limits = roi_limits;

        if P.batchSession
            resp = questdlg('Re-use ROI limits(s) for other batched process files?', '', 'Yes', 'No', 'Yes');
            if isequal(resp,'Yes')
                P.reuse_roi_limits = 1;
                P.reuse_roi_names = 1;
            elseif isequal(resp,'No')
                P.reuse_roi_limits = 0;
                resp = questdlg('Re-use ROI name(s) for other batched process files?', '', 'Yes', 'No', 'Yes');
                if isequal(resp,'Yes')
                    P.reuse_roi_names = 1;
                elseif isequal(resp,'No')
                    P.reuse_roi_names = 0;
                end
            end
        end

    elseif P.reuse_roi_names && ~P.reuse_roi_limits
        for r = 1:length(P.roi_names)
            repeat = false;
            while ~repeat
                disp(['Select ROI # ' num2str(r), ': ' P.roi_names]);
                imshow(frame)
                
                if r > 1
                   hold on;
                   for nroi = 1:(r-1)
                       plot(polyshape(P.roi_limits{nroi}), 'FaceAlpha', 0.25)
                   end
                end
                
                title(['Select ROI # ' num2str(r)]);
                roi = drawpolygon;
                roi_limits{r} = roi.Position;
                close;
                
                rsp = questdlg('Re-draw the ROI limits?', 'Confirm ROI Limits', 'Yes', 'No', 'No');
                if strcmp(rsp, 'Yes')
                    repeat = true;
                else
                    repeat = false;
                end
            end
        end
        P.roi_limits = roi_limits;
    end
end

end