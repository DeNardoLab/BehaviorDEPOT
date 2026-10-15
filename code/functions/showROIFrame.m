function showROIFrame(roiAxes, frame, previousROIs)
%showROIFrame Display a complete video frame and prior ROI context.

arguments
    roiAxes
    frame
    previousROIs cell
end

imshow(frame, 'Parent', roiAxes);
hold(roiAxes, 'on');
for roiIndex = 1:numel(previousROIs)
    roiPosition = previousROIs{roiIndex};
    if ~isempty(roiPosition)
        patch(roiAxes, roiPosition(:, 1), roiPosition(:, 2), ...
            [0.2 0.7 1.0], 'FaceAlpha', 0.20, 'EdgeColor', [0 0.4 0.8], ...
            'LineWidth', 1.5);
    end
end

[frameHeight, frameWidth, ~] = size(frame);
roiAxes.XLim = [0.5 frameWidth + 0.5];
roiAxes.YLim = [0.5 frameHeight + 0.5];
roiAxes.XLimMode = 'manual';
roiAxes.YLimMode = 'manual';
roiAxes.YDir = 'reverse';
roiAxes.DataAspectRatio = [1 1 1];
roiAxes.DataAspectRatioMode = 'manual';
axis(roiAxes, 'off');
end
