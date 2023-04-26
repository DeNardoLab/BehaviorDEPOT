% Classifier Optimization Module

% PURPOSE: Allow user to choose a behavior classifier and select a range of values to
% test (for 1 or 2 thresholds) and quickly run classifier to examine effects on classifier output;
% additionally, the user can include an hBehavior file to serve a ground
% truth for performance classification (reporting F1 score and ROC-based
% AUC values for range of tested parameters)

% INPUTS:
    % 1. BehaviorDEPOT '_analyzed' filepath
    % 2. Classifier to test
    % 3. Threshold values to evaluate (based on classifier)
    % 4. Filepath to associated hB file (or auto-detect)
    % 5. Behavior from hB to test
    
% OUTPUTS: 
    % 1. oResults
    
function classifier_optimization_module()
%% Initialization - Set required inputs

%% UPDATE TO ALLOW SELECTION OF PARENT DIRECTORY CONTAINING FOLDERS WITH PAIRED ANALZYED AND HB FILES
%% RUN PARAMETERS FOR ALL SESSIONS (CALCULATE SUMMARY STATS?)

single_sess = False;

if ~ispc
    menu('Select a BehDEPOT (_analyzed) or batch folder to use for optimization', 'OK')
end
input_filepath = uigetdir('','Select a BehDEPOT (_analyzed) or batch folder to use for optimization');

cd(input_filepath)

% Check if single or batch session
D_a = dir('Behavior.mat');
cd('..')
D_hB = dir('*hB*.mat');

if size(D_a, 1) + size(D_hB, 1) == 2
    single_sess = True;
end

if single_sess
    % Set input path as BD path and find hB file
    BD_filepath = input_filepath;
    data_dirs = {fileparts(BD_filepath)};

elseif batch_sess
    % Organize the data dirs (dirDirs)
    data_dirs = dirDirs(input_filepath);
end

module_path = mfilename('fullpath');

if ispc
    mp_slash = strfind(module_path, "\");
else
    mp_slash = strfind(module_path, "/");
end

app_path = module_path(1:mp_slash(end-1));
class_path = [app_path, 'classifiers'];

%% Main Script
for f = 1:size(data_dirs,1)

    cd(data_dirs{f})

    if single_sess
        if ~ispc
            menu('Select a hB file (output from convertHumanAnnotations.m)', 'OK')
        end
        [hB_file, hB_path] = uigetfile('','Select a hB file (output from convertHumanAnnotations.m)');
    else
        hB_search = dir('*hB_*.mat');
        if size(hB_search, 1) == 1
            hB_file = hB_search.name;
            hB_path = hB_search.folder;
        else
            disp(['Error finding hBehavior data in ' data_dirs{f}])
            disp('Cancelling analysis.')
            return
        end

        analyzed_search = dir('*_analyzed*');
        if size(analyzed_search, 1) == 1
            BD_filepath = [analyzed_search.folder, addSlash(), analyzed_search.name];
        else
            disp(['Error finding BehaviorDEPOT "_analyzed" data in ' data_dirs{f}])
            disp('Cancelling analysis.')
            return
        end
    end

    % Load data from hB file
    full_hB_path = [hB_path, hB_file];
    load(full_hB_path);
    
    if f == 1

        % Scan hBehavior contents for behaviors (i.e. structures)
        hB_fields = fieldnames(hBehavior);
        
        for i = 1:length(hB_fields)
            field_inds(i) = isstruct(hBehavior.(hB_fields{i}));
        end
        
        % Prompt user to select a behavior from human annotation file
        struct_fields = hB_fields(field_inds); 
        behav_ind = listdlg('PromptString', {'Select behavior to use from hB file'}, 'ListString', struct_fields, 'SelectionMode','single');
        behavior_to_test = struct_fields{behav_ind};
        ref = hBehavior.(behavior_to_test).Vector;
        
        cd(class_path)
        class_search = dir;
        class_search(1:2) = [];
        classifier_names = {};
        c = 1;
        
        for i = 1:size(class_search, 1)
            % Remove param files
            if ~startsWith(class_search(i).name, 'P_')
                classifier_names{c} = class_search(i).name;
                c = c + 1;
            end
        end
        
        % Prompt User to choose classifier
        disp('Select classifier file to test.')
        class_ind = listdlg('PromptString', {'Select classifier file to test.'}, 'ListString', classifier_names, 'SelectionMode', 'single');
        classifier = classifier_names{class_ind};
        classifier_noext = extractBefore(classifier, ".");
        class_fn = str2func(classifier_noext);
        
        % Load in data from analyzed filepath
        cd(BD_filepath)
        to_load = dir('*.mat');
        
        for i = 1:length(to_load)
            load(to_load(i).name)
        end
        
        % Copy Params and change thresholds
        testParams = Params;
        thresh_names = fieldnames(testParams.(behavior_to_test));
        
        ind1 = listdlg('PromptString', {'Select 1st parameter to test.'}, 'ListString', thresh_names, 'SelectionMode', 'single');
        ind2 = listdlg('PromptString', {'Select 2nd parameter to test.'}, 'ListString', thresh_names, 'SelectionMode', 'single');
        
        thresh1 = thresh_names(ind1);
        
        if size(ind2, 1) == 0
            thresh2 = thresh1;
            ind2 = ind1;
        else
            thresh2 = thresh_names(ind2);
        end
        
        if strcmp(thresh1, thresh2)
            answer = inputdlg({thresh1{1}}, 'Input values to test (comma separated)', [1 50]);
            thresh1_values = str2num(answer{1,1});
            thresh2_values = thresh1_values;
        else
            answer = inputdlg({thresh1{1}, thresh2{1}}, 'Input values to test (comma separated)', [1 50; 1 50]);
            thresh1_values = str2num(answer{1,1});
            thresh2_values = str2num(answer{2,1});
        end
        
        o_results.tested_classifier = behavior_to_test;
        o_results.thresh1 = thresh1;
        o_results.thresh1_values = thresh1_values;
        o_results.thresh2 = thresh2;
        o_results.thresh2_values = thresh2_values;
    end

    % Run chosen classifier on selected parameter range (multiplexed)
    t1_size = length(thresh1_values);
    t2_size = length(thresh2_values);

    TP = zeros(t1_size,t2_size);
    TN = zeros(t1_size,t2_size);
    FP = zeros(t1_size,t2_size);
    FN = zeros(t1_size,t2_size);
    precision = zeros(t1_size,t2_size);
    recall = zeros(t1_size,t2_size);
    f1_score = zeros(t1_size,t2_size);
    
    for p1 = 1:length(thresh1_values)
        testParams.(behavior_to_test).(thresh1{1}) = thresh1_values(p1);
        for p2 = 1:length(thresh2_values)
            testParams.(behavior_to_test).(thresh2{1}) = thresh2_values(p2); 
            testBehavior = class_fn(testParams, Tracking, Metrics);
            cmp = testBehavior.Vector;
            if size(cmp, 2) < size(cmp, 1)
                cmp = cmp';
            end
            error = ref - cmp;
            tp = zeros(length(error),1);
            tn = zeros(length(error),1);
            for r = 1:length(error)
                if error(r) == 0 && ref(r) == 1
                    tp(r) = 1;
                elseif error(r) == 0 && ref(r) == 0
                    tn(r) = 1;
                end
            end
            fp = (error == -1); 
            fn = (error == 1);
            
            TP(p1, p2) = sum(tp);
            TN(p1, p2) = sum(tn);
            FP(p1, p2) = sum(fp);
            FN(p1, p2) = sum(fn);
            
            % Calculate Precision, Recall, & F1 Score
            precision(p1, p2) = TP(p1, p2) / (TP(p1, p2) + FP(p1, p2));
            recall(p1, p2) = TP(p1, p2) / (TP(p1, p2) + FN(p1, p2));
            f1_score(p1, p2) = (2*precision(p1, p2)*recall(p1, p2)) / (precision(p1, p2) + recall(p1, p2));
            
        end
    end
    
    %% Prep Save Folder
    mkdir('Optimization_Results')
    cd('Optimization_Results')
    
    %% FIGURES 1 & 2: Generate Heatmaps of F1 Scores versus parameter value
    f1 = figure(1);
    subplot(2,1,1)
    heatmap(compose('%.2f',thresh2_values), compose('%.2f',thresh1_values), precision)
    xlabel(thresh2)
    ylabel(thresh1)
    title('Precision')
    subplot(2,1,2)
    heatmap(compose('%.2f',thresh2_values), compose('%.2f',thresh1_values), recall)
    xlabel(thresh2)
    ylabel(thresh1)
    title('Recall')
    savefig(f1, 'Precision_Recall')
    saveas(f1, 'Precision_Recall.jpg')
    close(f1)
    
    f2 = figure(2);
    heatmap(compose('%.2f',thresh2_values), compose('%.2f',thresh1_values), f1_score)
    xlabel(thresh2)
    ylabel(thresh1)
    title('F1 Score')
    savefig(f2, 'F1_Scores')
    saveas(f2, 'F1 Scores.jpg')
    close(f2)
    
    %% Organize Data into oResults structure
    
    oResults.data_filepath = BD_filepath;
    oResults.hB_file = full_hB_path;
    oResults.tested_classifier = behavior_to_test;
    oResults.thresh1 = thresh1;
    oResults.thresh1_values = thresh1_values;
    oResults.thresh2 = thresh2;
    oResults.thresh2_values = thresh2_values;
    oResults.precision = precision;
    oResults.recall = recall;
    oResults.f1_score = f1_score;
    
    %% Save oResults structure
    save([behavior_to_test, '_oResults.mat'], 'oResults')
    
    %% Save data to group structure
    o_results.data_filepath(f) = BD_filepath;
    o_results.hB_file(f) = full_hB_path;
    o_results.precision(f) = precision;
    o_results.recall(f) = recall;
    o_results.f1_score(f) = f1_score;

    %% Save vars needed for batch
    clearvars -except data_dirs thresh1_values thresh2_values f input_filepath o_results behavior_to_test
end

if ~single_sess
    % Generate and save group oResults structure to data_dir
    o_results.AvgPrecision = mean(o_results.precision);
    o_results.AvgRecall = mean(o_results.recall);
    o_results.AvgF1 = mean(o_results.f1_score);

    cd(input_filepath)

    save(['Group ' behavior_to_test ' oResults.mat'], 'oResults')
end
end