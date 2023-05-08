%importDLCTracking

%INPUT: Params (session parameters structure)
%OUTPUT: data, Params (generic variable containing imported DLC data)
%FUNCTION: import DLC CSV/H5 file  

function [data, Params] = importDLCTracking(Params)
    data = [];
    cd(Params.basedir);
    disp('Reading tracking file')
    % Check if CSV file
    if contains(Params.tracking_type, 'csv')
        % Check if tracking_file is known
        if ~isfield(Params,'tracking_file')
            S = dir('*.csv');
            if length(S) > 1  % differentiate cue and tracking csv files
                [~,vid_name] = fileparts(Params.video_file);
                for s = 1:length(S)
                    if contains(S(s).name, vid_name) && ~contains(S(s).name, 'cue', 'IgnoreCase', true)
                        trackfile = s;
                    end
                end
            else
                trackfile = 1;
            end
            Params.tracking_file = [S(trackfile).folder, addSlash(), S(trackfile).name];
        end
        
        % Import data from CSV file
        opts = detectImportOptions(Params.tracking_file);
        M = readmatrix(Params.tracking_file, 'Range', [4,2]);
        data = M';
        M2 = readcell(Params.tracking_file, 'Range', [2,2,2,length(opts.VariableNames)]);        
        part_names = M2(1:3:end);
        disp('DeepLabCut CSV Loaded');
    % Check if H5 file
    elseif contains(Params.tracking_type, 'h5')
        if ~isfield(Params,'tracking_file')
            S = dir('*.h5');
            if size(S, 1) == 1
                trackfile = 1;
            elseif size(S, 1) > 1
                [~,vid_name] = fileparts(Params.video_file);
                for s = 1:length(S)
                    if contains(S(s).name, vid_name)
                        trackfile = s;
                    end
                end
            end
            Params.tracking_file = [S(trackfile).folder, addSlash(), S(trackfile).name];
        end
        
        % Collect tracking xy data and likelihood and save to 'data'
        dataAdd = h5read(Params.tracking_file, '/df_with_missing/table');
        data = dataAdd.values_block_0;

        % Collect labels from attribute file
        info = h5readatt(Params.tracking_file, '/df_with_missing/table', 'values_block_0_kind');
        split_info = split(info, 'V');
        potential_labels = cell(1, size(split_info, 1));

        for i = 1:length(split_info)
            temp = split(split_info{i}, newline);
            potential_labels(i) = temp(1);
        end
        
        part_names = potential_labels([3,7:size(potential_labels,2)]);
        disp('DeepLabCut H5 Loaded');
    end
    
    % remove characters from names that may break the code
    part_names = cleanText(part_names);
    Params.part_names = part_names;

end
