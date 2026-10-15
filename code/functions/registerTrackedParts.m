function partMatchInds = registerTrackedParts( ...
        partNames, knownPartList, Tracking, previewFrame, previewFrameIdx, ...
        defaultPartMatchInds)
%registerTrackedParts Map detected tracking labels to known body parts.

arguments
    partNames cell
    knownPartList cell
    Tracking struct
    previewFrame
    previewFrameIdx
    defaultPartMatchInds {mustBeNumeric, mustBeVector} = []
end

numParts = numel(partNames);
otherIndex = find(strcmp(knownPartList, 'Other'), 1);
if isempty(otherIndex)
    error('BehaviorDEPOT:registerTrackedParts:MissingOtherPart', ...
        'Known-part definitions must include Other.');
end

if isempty(defaultPartMatchInds)
    defaultPartMatchInds = repmat(otherIndex, 1, numParts);
else
    defaultPartMatchInds = validatePartMatchInds( ...
        defaultPartMatchInds, knownPartList, numParts);
end

mappingFigure = uifigure( ...
    'Name', 'Register Tracked Parts', ...
    'WindowStyle', 'modal', ...
    'Position', getPipelineWindowPosition(0.90, 0.88, 1000, 650), ...
    'CloseRequestFcn', @cancelRegistration);

mainGrid = uigridlayout(mappingFigure, [3 1]);
mainGrid.RowHeight = {'fit', '1x', 'fit'};
mainGrid.Padding = [15 15 15 15];
mainGrid.RowSpacing = 10;

instructions = uilabel(mainGrid, ...
    'Text', ['Match each detected tracking label to a known body part. ', ...
             'Each named body part may be used once; select Other for ', ...
             'unlisted or additional points.'], ...
    'WordWrap', 'on');
instructions.Layout.Row = 1;

contentPanel = uipanel(mainGrid, 'Title', 'Review Tracking and Register Parts');
contentPanel.Layout.Row = 2;
contentGrid = uigridlayout(contentPanel, [1 2]);
contentGrid.ColumnWidth = {'1x', '1x'};
contentGrid.Padding = [10 10 10 10];
contentGrid.ColumnSpacing = 12;

previewPanel = uipanel(contentGrid, 'Title', 'Example Tracking Data');
previewPanel.Layout.Row = 1;
previewPanel.Layout.Column = 1;
previewGrid = uigridlayout(previewPanel, [1 1]);
previewGrid.Padding = [5 5 5 5];
previewAxes = uiaxes(previewGrid);
previewAxes.Layout.Row = 1;
previewAxes.Layout.Column = 1;
plotPointTracking(Tracking, struct('part_names', {partNames}), ...
    previewFrame, previewFrameIdx, previewAxes);

mappingPanel = uipanel(contentGrid, 'Title', 'Detected Part Mapping', ...
    'Scrollable', 'on');
mappingPanel.Layout.Row = 1;
mappingPanel.Layout.Column = 2;

mappingGrid = uigridlayout(mappingPanel, [numParts + 1 2]);
mappingGrid.RowHeight = repmat({'fit'}, 1, numParts + 1);
mappingGrid.ColumnWidth = {'fit', '1x'};
mappingGrid.Padding = [10 10 10 10];
mappingGrid.RowSpacing = 6;
mappingGrid.ColumnSpacing = 12;

detectedHeader = uilabel(mappingGrid, 'Text', 'Detected part', ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'right');
detectedHeader.Layout.Row = 1;
detectedHeader.Layout.Column = 1;
knownHeader = uilabel(mappingGrid, 'Text', 'Known part', ...
    'FontWeight', 'bold');
knownHeader.Layout.Row = 1;
knownHeader.Layout.Column = 2;

dropdowns = gobjects(1, numParts);
for partIndex = 1:numParts
    detectedLabel = uilabel(mappingGrid, 'Text', partNames{partIndex}, ...
        'Interpreter', 'none', 'HorizontalAlignment', 'right');
    detectedLabel.Layout.Row = partIndex + 1;
    detectedLabel.Layout.Column = 1;

    dropdowns(partIndex) = uidropdown(mappingGrid, ...
        'Items', knownPartList, ...
        'Value', knownPartList{defaultPartMatchInds(partIndex)});
    dropdowns(partIndex).Layout.Row = partIndex + 1;
    dropdowns(partIndex).Layout.Column = 2;
end

buttonGrid = uigridlayout(mainGrid, [1 2]);
buttonGrid.ColumnWidth = {'1x', '1x'};
buttonGrid.ColumnSpacing = 10;
buttonGrid.Padding = [0 0 0 0];
buttonGrid.Layout.Row = 3;

uibutton(buttonGrid, 'Text', 'Cancel', ...
    'ButtonPushedFcn', @cancelRegistration);
uibutton(buttonGrid, 'Text', 'Confirm Mapping', ...
    'ButtonPushedFcn', @confirmRegistration);

mappingFigure.UserData = struct('Confirmed', false, 'PartMatchInds', []);
uiwait(mappingFigure);

registration = mappingFigure.UserData;
delete(mappingFigure);
if ~registration.Confirmed
    error('BehaviorDEPOT:calculateMetrics:PartRegistrationCanceled', ...
        'Tracked-part registration was canceled.');
end
partMatchInds = registration.PartMatchInds;

    function confirmRegistration(~, ~)
        selectedParts = arrayfun(@(dropdown) dropdown.Value, dropdowns, ...
            'UniformOutput', false);
        try
            selectedInds = validatePartMatchInds( ...
                cellfun(@(part) find(strcmp(knownPartList, part), 1), ...
                selectedParts), knownPartList, numParts);
        catch exception
            uialert(mappingFigure, exception.message, 'Invalid Part Mapping', ...
                'Icon', 'error');
            return
        end

        mappingFigure.UserData = struct( ...
            'Confirmed', true, 'PartMatchInds', selectedInds);
        uiresume(mappingFigure);
    end

    function cancelRegistration(~, ~)
        mappingFigure.UserData = struct('Confirmed', false, 'PartMatchInds', []);
        uiresume(mappingFigure);
    end
end
