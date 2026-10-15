function [output, Params, P] = calculateUserEvents(Params, P)

if ~isfield(P, 'noninteractive')
    P.noninteractive = false;
end

numFrames = Params.numFrames;
cue_files = Params.cueFile;

% prompt for number of timestamp files
tf = 0;
if isempty(cue_files) && P.noninteractive
    error('BehaviorDEPOT:calculateUserEvents:MissingCueFiles', ...
        'Noninteractive event filtering requires P.cueFile or P.cueFiles.');
elseif isempty(cue_files) && ~Params.batchSession
    if P.noninteractive
        error('BehaviorDEPOT:calculateUserEvents:MissingCueFiles', ...
            'Noninteractive event filtering requires P.cueFile or P.cueFiles.');
    end
    while ~tf
    [numfiles,tf] = listdlg('PromptString','Number of timestamp files','ListString',{'1','2','3'}, 'SelectionMode','single');
    end
elseif iscell(cue_files)
    numfiles = numel(cue_files);
elseif isstring(cue_files) && numel(cue_files) > 1
    cue_files = cellstr(cue_files);
    numfiles = numel(cue_files);
else
    numfiles = 1;
end

Params.num_events = numfiles;

% get cue file name if not previously saved
for f = 1:numfiles
    if isfield(P, 'eventname') && ~isempty(P.eventname)
        if iscell(P.eventname)
            eventname = P.eventname{f};
        elseif isstring(P.eventname) && numel(P.eventname) > 1
            eventname = char(P.eventname(f));
        else
            eventname = char(P.eventname);
        end
    elseif P.noninteractive
        if numfiles == 1
            eventname = 'Event';
        else
            eventname = ['Event' num2str(f)];
        end
    elseif isempty(P.reuse_cue_names) || P.reuse_cue_names == false
        if numfiles >= 1
            prompt = {'Assign name to time cues'};
            dlgtitle = 'Input';
            dims = [1 40];
            definput = {'Event'};
            eventname = inputdlg(prompt,dlgtitle,dims,definput);
            eventname = cleanText(eventname);
            eventname = char(eventname);
        end
    elseif P.reuse_cue_names
        eventname = P.eventname;    
    end
    
    if Params.batchSession && isempty(P.reuse_cue_names)
        resp = questdlg('Re-use time cue name for other batched process files?', 'Reuse Cue Names?', 'Yes', 'No', 'No');
        if isequal(resp,'Yes')
            P.reuse_cue_names = true;
            Params.reuse_cue_names = true;
            P.eventname = eventname;
        elseif isequal(resp,'No')
            P.reuse_cue_names = false;
        end
    end
        
    % load event times
    if isempty(cue_files)
        disp(['Select file containing timestamps for ' eventname])
        cue_start_folder = localCueStartFolder(Params, P);
        [filename, file_path] = uigetfile(fullfile(cue_start_folder, '*.*'), ...
            'Select file containing timestamps for events');
        eventmat = readmatrix(fullfile(file_path, filename));
    elseif iscell(cue_files)
        eventmat = readmatrix(cue_files{f});
    elseif isstring(cue_files) && numel(cue_files) > 1
        eventmat = readmatrix(cue_files(f));
    else
        eventmat = readmatrix(cue_files);
    end

    % convert event times to vector
    output.(eventname) = genBehStruct(eventmat(:,1), eventmat(:,2), numFrames);

end
end

function folder = localCueStartFolder(Params, P)
if isfield(P, 'basedir') && ~isempty(P.basedir)
    folder = P.basedir;
elseif isfield(Params, 'basedir') && ~isempty(Params.basedir)
    folder = Params.basedir;
else
    folder = pwd;
end
end
