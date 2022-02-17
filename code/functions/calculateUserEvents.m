function [output, Params, P] = calculateUserEvents(Params, P)
    
    numframes = Params.numFrames;
    
    % prompt for number of timestamp files
    tf = 0;
    if isempty(Params.cueFile)
        while ~tf
        [numfiles,tf] = listdlg('PromptString','Number of timestamp files','ListString',{'1','2','3'}, 'SelectionMode','single');
        end
    else
        numfiles = 1;
    end
    
    Params.num_events = numfiles;
    
    % get cue file name if not previously saved
    for f = 1:numfiles
        if isempty(P.reuse_cue_name) || P.reuse_cue_name == 0
            if numfiles >= 1
                prompt = {'Assign name to time cues'};
                dlgtitle = 'Input';
                dims = [1 40];
                definput = {'Event'};
                eventname = inputdlg(prompt,dlgtitle,dims,definput);
                eventname = cleanText(eventname);
                eventname = char(eventname);
            end
        elseif P.reuse_cue_name ==  1
            eventname = P.eventname;    
        end
        
        if Params.batch && isempty(Params.reuse_cue_name)
            resp = questdlg('Re-use time cue name for other batched process files?', '', 'Yes', 'No', 'Yes');
            if isequal(resp,'Yes')
                Params.reuse_cue_name = 1;
                P.reuse_cue_name = 1;
                P.eventname = eventname;
            elseif isequal(resp,'No')
                Params.reuse_cue_name = 0;
                P.reuse_cue_name = 0;
            end
        end
            
        % load event times
        if isempty(Params.cueFile)
            disp(['Select file containing timestamps for ' eventname])
            [filename, file_path] = uigetfile('*.*','Select file containing timestamps for events');
            eventmat = readmatrix([file_path filename]);
        else
            eventmat = readmatrix(Params.cueFile);
        end

        % convert event times to vector
        event_vec = zeros(1, numframes);
        for i = 1:size(eventmat,1)
            event_vec(1, eventmat(i,1):eventmat(i,2)) = 1;
        end
    end
end