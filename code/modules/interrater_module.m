% compares freezing scores between automatically and manually scored ratins
% INPUT:  Behavior struct from main code, names cell array containing str
% names of user ratings.
% User is prompted for files containing user scored bouts (files should
% contain 2 column matrix, col(1) = start frame of bout, col(2) = end frame

% INPUT: hB or B files
% OUTPUT: IR_Results structure

function interrater_module(P)

analyzed_ID = '*_analyzed';
hB_ID = 'hB_*';

% get input directory, gather file names and get custom rater names
msgbox('Select directory containing rater files')
pause(2);
working_directory = uigetdir('','Select directory containing rater files');

cd(working_directory)
% all_files = dir2(working_directory);
analyzed_search = dir(analyzed_ID);
hB_search = dir(hB_ID);
hB_names = {};
names = {};
for i = 1:size(hB_search,1)
    if ~ispc
        hB_files{i} = [hB_search(i).folder '/' hB_search(i).name];
    else
        hB_files{i} = [hB_search(i).folder '\' hB_search(i).name];
    prompt = {['Assign name to rater file: ' hB_search(i).name]};  
    dlgtitle = 'Input';
    dims = [1 40];
    definput = {''};
    i_name = inputdlg(prompt,dlgtitle,dims,definput);
    hB_names{i} = string(i_name);
end

if size(analyzed_search, 1) >= 1
    for i = 1:size(analyzed_search, 1)
        if ~ispc
            analyzed_files{i} = [analyzed_search(i).folder '/' analyzed_search(i).name '/Behavior.mat'];
        else
            analyzed_files{i} = [analyzed_search(i).folder '\' analyzed_search(i).name '\Behavior.mat'];
        end
        prompt = {['Assign name to rater file: ' analyzed_search(i).name]};
        dlgtitle = 'Input';
        dims = [1 40];
        definput = {''};
        i_name = inputdlg(prompt,dlgtitle,dims,definput);
        analyzed_names{i} = string(i_name);
    end
else
    analyzed_files = {};
    analyzed_names = {};
end

files = [hB_files, analyzed_files];
names = [hB_names, analyzed_names];
names = cleanText(names);

% optional:  filter out user specified rater from comparison
if P.do_subset
    [s,v] = listdlg('PromptString','Select user(s) to EXCLUDE from comparison:',...
        'SelectionMode','multi','ListString',names, 'CancelString', 'Include All',...
        'ListSize', [300 300]);
    if v == 1
        if ~isempty(s)
            names(s) = '';
            %names(~cellfun('isempty',names));
            hB_names(s) = '';
            %file_names = file_names(~cellfun('isempty',file_names));
        end
    end
end

names_avg = names; names_avg(end+1) = {'Average'};
avg_key = length(names)+1;  % reference key for choice of average

% create dialog to pick reference rater, or average
disp('Select rater to use as reference. Select "average" to use average of all raters')
[indx,~] = listdlg('PromptString',{'Select rater to use as reference. Select "average" to use average of all raters'},'SelectionMode','single','ListString',names_avg);

reference_number = indx; %Sets the reference for performance/error calculations

generate_error_tables = 1; %Generates .txt files containing spans of FP/FN errors with index values
results_filename = "IR_Results"; %Name of output file

%% Load In Annotations Files From file_names

IR_Results.working_directory = working_directory;
IR_Results.names = names;
IR_Results.reference_number = reference_number;

if reference_number == avg_key
    IR_Results.reference_name = 'averaged raters';
else
    IR_Results.reference_name = names{reference_number};
end

cd(working_directory)

rater_data(1).Behavior = [];

for i = 1:length(files)
    structtmp = load(char(files(i)));
    sn = string(fieldnames(structtmp));
    rater_data(i).Behavior = structtmp.(sn);
    clearvars struct sn
end

%% Determine Behaviors to Compare

% Remove non-structure data (e.g. video info)
for i = 1:length(rater_data)
    fnames = fieldnames(rater_data(i).Behavior);
    f_include = zeros(length(fnames), 1);
    
    for ii = 1:length(fnames)
        f_include(ii) = isstruct(rater_data(i).Behavior.(fnames{ii}));
    end

    f_exclude = ~f_include;
    remove = fnames(f_exclude);
    
    rater_data(i).Behavior = rmfield(rater_data(i).Behavior, remove);
    
    clearvars fnames f_include f_exclude remove
end

%% Generate list of behaviors to consider
behavs_to_consider = {};

for i = 1:length(rater_data)
    behavs_to_consider = cat(1, behavs_to_consider, fieldnames(rater_data(i).Behavior));
end

unique_behavs = unique(behavs_to_consider);
X = repmat(behavs_to_consider', length(unique_behavs), 1);
Y = repmat(unique_behavs, 1, size(behavs_to_consider, 1));
behav_counts = sum(strcmpi(X, Y), 2);
behav_choices = unique_behavs(behav_counts > 1);
behav_ind = listdlg('PromptString',{'Select behavior to compare raters across:'},'SelectionMode','single','ListString',behav_choices);
behav_selected = behav_choices(behav_ind);

clearvars behavs_to_consider behav_counts
%% Loop through all behaviors to analyze

for b = 1:length(behav_selected)
    % Load relevant data
    
    data = struct('Bouts', [], 'Length', [], 'Count', [], 'Vector', [], 'Name', {});
    dataNames = {};
    
    c = 0;
    for ii = 1:length(rater_data)
        if isfield(rater_data(ii).Behavior, behav_selected{b})
            rater_data(ii).Behavior.(behav_selected{b}).Name = names{ii};
            c = c + 1;
            dataNames(c) = names(ii);
            data(c) = rater_data(ii).Behavior.(behav_selected{b});
        end
    end
    
    IR_Results.(behav_selected{b}).names = dataNames;
    
    %% Generate multidimensional array with errors relative to all other raters

    % when accessing error_vector(j,i,:) --> j = reference; i = comparison
    % +1 = false negative; -1 = false positive (relative to reference, j)
    
%%%%% error_frames = zeros(length(filenames), length(filenames), length(
    agreement_vector = zeros(length(data(1).Vector), 1);

    for j = 1:length(data)
        for i = 1:length(data)
            error_vector(j, i, :) = data(j).Vector - data(i).Vector;
        end
        agreement_vector = agreement_vector + data(j).Vector;
    end

    total_frames = size(error_vector, 3);
    
    IR_Results.(behav_selected{b}).agreement = agreement_vector;
    
    %% Compare Percent Overlap between each set of Annotations

    percent_overlap = sum(~abs(error_vector), 3) / total_frames;
    percent_error = sum(abs(error_vector), 3) / total_frames;

    IR_Results.(behav_selected{b}).percent_overlap = sum(~abs(error_vector), 3) / total_frames;
    IR_Results.(behav_selected{b}).percent_error = sum(abs(error_vector), 3) / total_frames;

    %% Calculate Disagreement Score
    
    disagreement_score = squeeze(sum(abs(error_vector), 1));
    IR_Results.(behav_selected{b}).disagreement = disagreement_score;

    clearvars disagreement_score agreement_vector percent_overlap percent_error
    
    %% Calculate Fleiss's Kappa
    
    %% Select/generate reference data

    comp_inds = ones(1, length(rater_data));
    
    if reference_number == avg_key
        for i = 1:length(data)
            ref_data(i, :) = data(i).Vector;
        end
        ref_data = nanmean(ref_data, 1);
        ref_data = ref_data >= 0.5;
    else
        ref_data = data(reference_number).Vector';
        comp_inds(reference_number) = 0;
    end
    
    comp_inds = find(comp_inds);
    comp_data = zeros(length(data), total_frames);
    
    for i = 1:length(data)
        comp_data(i, :) = data(i).Vector';
    end
    
    %% Calculate TP, TN, FP, FN for each comparison
    
    error_matrix = ref_data - comp_data;
    TP = zeros(length(hB_names), total_frames);
    TN = zeros(length(hB_names), total_frames);
    
    for i = 1:size(error_matrix, 1)
        for ii = 1:total_frames
            if (error_matrix(i, ii) == 0) & (ref_data(ii) == 1)
                TP(i, ii) = 1;
            elseif (error_matrix(i, ii) == 0) & (ref_data(ii) == 0)
                TN(i, ii) = 1;
            end
        end
    end
    
    FP = double(error_matrix == 1);
    FN = double(error_matrix == -1);
    
    %% Calculate Precision & Recall
    
    precision = zeros(size(error_matrix, 1), 1);
    recall = zeros(size(error_matrix, 1), 1);
    specificity = zeros(size(error_matrix, 1), 1);
    f1_score = zeros(size(error_matrix, 1), 1);

    
    for i = 1:size(error_matrix, 1)
        precision(i) = sum(TP(i,:)) / sum(FP(i,:) + TP(i,:));
        recall(i) = sum(TP(i,:)) / sum(FN(i,:) + TP(i,:));
        specificity(i) = sum(TN(i,:)) / sum(TN(i,:) + FP(i,:));
    end
    
    f1_score = 2 * ((precision .* recall) ./ (precision + recall));

    IR_Results.(behav_selected{b}).precision = precision;
    IR_Results.(behav_selected{b}).recall = recall;
    IR_Results.(behav_selected{b}).specificity = specificity;
    IR_Results.(behav_selected{b}).f1_score = f1_score;
    
    %% Calculate and Report Regions with Large Consecutive Errors (relative to reference)

    if generate_error_tables
        %Generate error structures
        %Log behavior in title (save all files in a single directory)

        for i = 1:length(data)
            fp(i).inds = find(FP(i,:));
            if ~isempty(fp(i).inds)
                fp(i).spans = diff(fp(i).inds);
                fp(i).spans = [1.5, fp(i).spans]; %Add filler value (1.5)
            end
            fn(i).inds = find(FN(i,:));
            if ~isempty(fn(i).inds)
                fn(i).spans = diff(fn(i).inds);
                fn(i).spans = [1.5, fn(i).spans]; %Add filler value (1.5)
            end
        end

        %% Construct a table with FP and FN inds (start:stop) and the span length
        errors = struct('start', [], 'stop', [], 'length', [], 'type', []);
        p = fp.inds;
        n = fn.inds;
        
        for j = 1:length(data)
            if ~isempty(p)
                count = 0;
                errors(1,j).type = 'FP';
                for i = 1:length(fp(j).spans)
                    if fp(j).spans(i) > 1
                        if count >= 1
                            errors(1,j).stop(count) = fp(j).inds(i-1);
                        end
                        count = count + 1;
                        errors(1,j).start(count) = fp(j).inds(i);
                    end
                    if length(errors(1,j).start) > length(errors(1,j).stop)
                        errors(1,j).stop(count) = fp(j).inds(end);
                    end
                end
            end
            
            if ~isempty(n)
                count = 0;
                errors(2,j).type = 'FN';
                for i = 1:length(fn(j).spans)
                    if fn(j).spans(i) > 1
                        if count >= 1
                            errors(2,j).stop(count) = fn(j).inds(i-1);
                        end
                        count = count + 1;
                        errors(2,j).start(count) = fn(j).inds(i);
                    end
                    if length(errors(2,j).start) > length(errors(2,j).stop)
                        errors(2,j).stop(count) = fn(j).inds(end);
                    end
                end
            end    
        end

        clearvars fn fp
        
        for i = 1:length(data)
            if ~isempty(p)
                errors(1,i).length = errors(1,i).stop - errors(1,i).start;
            end
            if ~isempty(n)
                errors(2,i).length = errors(2,i).stop - errors(2,i).start;
            end
        end
        %% Sort table by span length (largest to smallest)

        for j = 1:length(data)
            skip = 0;
            %Assemble table (per user)
            if isempty(p) & ~isempty(n)
                Start = [errors(2,j).start]';
                Stop = [errors(2,j).stop]';
                Length = [errors(2,j).length]';
                [type_fn{1:length(errors(2,j).start)}] = deal('FN');
                Type = [type_fn]';
                error_table = table(Start, Stop, Length, Type);
            elseif ~isempty(p) & isempty(n)
                Start = [errors(1,j).start]';
                Stop = [errors(1,j).stop]';
                Length = [errors(1,j).length]';
                [type_fp{1:length(errors(1,j).start)}] = deal('FP');
                Type = [type_fp]';
                error_table = table(Start, Stop, Length, Type);
            elseif isempty(p) & isempty(n)
                skip = 1;
            else
                Start = [errors(1,j).start, errors(2,j).start]';
                Stop = [errors(1,j).stop, errors(2,j).stop]';
                Length = [errors(1,j).length, errors(2,j).length]';
                [type_fp{1:length(errors(1,j).start)}] = deal('FP');
                [type_fn{1:length(errors(2,j).start)}] = deal('FN');
                Type = [type_fp, type_fn]';
                error_table = table(Start, Stop, Length, Type);
            end
            
            if ~skip
            %Sort table
            [~, sort_order] = sortrows(error_table.Length, 'descend');
            error_table = error_table(sort_order,:);

            %Save table within loop  
            mkdir('Error tables')
            cd('Error tables')
            if ~isequal(reference_number, avg_key)
                filename = behav_selected{b} + "_Ref_" + names{reference_number} + "_Comp_" + names{j};
            else
                filename = behav_selected{b} + "_Ref_Average" + "_Comp_" + names{j};
            end
            writetable(error_table, filename)
            cd(working_directory)
            end
            clearvars Start Stop Length Type type_fn type_fp sort_order error_table filename skip
        end
    end
end

%% save results
results_filename_ext = strcat(results_filename, '.mat');
save(results_filename_ext, 'IR_Results')
msgbox('Interrater comparison complete; results saved in data directory')

%% do plots
save_fig = 1;

% iterate through behaviors
for b = 1:length(behav_selected)
    behavior = behav_selected{b};
    
    if P.do_disagreement
        IR_disagreement(IR_Results, behavior, save_fig);
    end

    if P.do_percent_agreement
        IR_percent_agreement(IR_Results, behavior, save_fig);
    end

    if P.do_percent_overlap
        IR_percent_overlap(IR_Results, behavior, save_fig);
    end

    if P.do_IR_performance
        IR_performance(IR_Results, behavior, save_fig);
    end

%     if P.visualize_annotations
%         IR_visualize_annotations(IR_Results, save_fig);
%     end
end
    
    
end