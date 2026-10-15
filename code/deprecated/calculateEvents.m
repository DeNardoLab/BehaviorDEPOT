function [output, Params, P] = calculateEvents(Behavior, Params, P)
    
    tmpbeh = struct2cell(Behavior);
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
            [f p] = uigetfile('*.*','Select file containing timestamps for events');
            eventmat = readmatrix([p f]);
        else
            eventmat = readmatrix(Params.cueFile);
        end

        % convert event times to vector
        event_vec = zeros(1,numframes);
        for i = 1:size(eventmat,1)
            event_vec(1, eventmat(i,1):eventmat(i,2)) = 1;
        end

        % loop through behaviors 
        beh_name = fieldnames(Behavior);
        beh_cell = struct2cell(Behavior);
        eventstats = [eventname '_PerBehDuringCue'];
        for i = 1:length(beh_cell)   % loop through behaviors
            i_beh_name = string(beh_name(i));  % load behvavior name
            i_beh_vec = beh_cell{i}.Vector;   % load behavior vector

            in_event_beh = find(event_vec == 1 & i_beh_vec == 1);
            in_event_beh_vec = zeros(size(i_beh_vec));
            in_event_beh_vec(in_event_beh) = 1;
            per_event_beh = sum(in_event_beh_vec) / sum(i_beh_vec);

            output.(eventname).EventVector = event_vec;
            output.(eventname).EventBouts = eventmat;
            output.(eventname).(i_beh_name).BehInEventVector = in_event_beh_vec;
            
            output.(eventname).(i_beh_name).Cue_BehInEventVector = [];
            for cue = 1:size(eventmat,1)
                this_cue = in_event_beh_vec(eventmat(cue,1):eventmat(cue,2))';
                output.(eventname).(i_beh_name).Cue_BehInEventVector = [output.(eventname).(i_beh_name).Cue_BehInEventVector; this_cue];
            end
            output.(eventname).(i_beh_name).PerBehInEvent = per_event_beh;
            
            for j = 1:size(eventmat,1)
                j_beh_vec = i_beh_vec(eventmat(j,1):eventmat(j,2));
                stats{j} = sum(j_beh_vec) / length(j_beh_vec);                
            end
            output.(eventname).(i_beh_name).PerBehDuringCue = stats;
        end
    end
end