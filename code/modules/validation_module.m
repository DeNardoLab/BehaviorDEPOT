% Validation Module
% required dir structure:  grandparent \ dir1, dir2, dirN...
% dir contrains exclusively hB file and Behavior file,

function validation_module()
%% Initialization - Required Inputs
hB_ID = 'hB*'; %Identifier for human annotation files
msgbox('Select directory containing folders with paired hB (output from convertHumanAnnotations) and Behavior.mat (output from classifier) files')
pause(2);
data_directory = uigetdir('','Select directory containing data folders with hB and Behavior files');
homedir = pwd;
%%
%cd(data_directory);
to_validate = prepBatch(data_directory);

for file_num = 1:length(to_validate)
    % cd into correct directory
    d_folder = to_validate(file_num);
    cd(d_folder)
    
    % Find data files (Behavior and hB files)
    comp_search = dir('Behavior.mat');
    ref_search = dir(hB_ID);
    
    if size(ref_search, 1) == 1
        ref_file = ref_search.name;
    else
        disp('Error: Reference data not found')
    end
    
    if size(comp_search, 1) == 1
        comp_file = comp_search.name;
    else
        disp('Error: Behavior data not found')
    end
    
    % Load data
    load(ref_file);
    load(comp_file);
    
    VResults.ReferenceFiles(file_num, :) = string(ref_file);
    VResults.ComparisonFiles(file_num, :) = string(comp_file);
    
    % Identify relevant data from Behavior and hBehavior
    ref_fields = fieldnames(hBehavior);
    comp_fields = fieldnames(Behavior);
    
     [s,v] = listdlg('PromptString','Select behavior to validate:',...
        'SelectionMode','single','ListString',comp_fields);
    
    behav_to_validate = (comp_fields{s});
    
    rf_ind = find(strcmpi(ref_fields, behav_to_validate));
    cf_ind = find(strcmpi(comp_fields, behav_to_validate));
    
    rf_name = ref_fields(rf_ind);
    cf_name = comp_fields(cf_ind);
    
    % Access data and prep for comparison
    ref_data = hBehavior.(rf_name{1}).Vector;
    comp_data = Behavior.(cf_name{1}).Vector;
    
    % Compare data by accessing behavior vectors
    error_matrix = ref_data - comp_data;
    total_frames = length(error_matrix);
    
    % Sort data into TP, TN, FP, FN   
    TP = zeros(total_frames, 1);
    TN = zeros(total_frames, 1);
    
    for ii = 1:total_frames
        if (error_matrix(ii) == 0) & (ref_data(ii) == 1)
            TP(ii) = 1;
        elseif (error_matrix(ii) == 0) & (ref_data(ii) == 0)
            TN(ii) = 1;
        end
    end
    
    FP = error_matrix == 1;
    FN = error_matrix == -1;
    
    VResults.FalsePositives(file_num) = sum(FP);
    VResults.FalseNegatives(file_num) = sum(FN);
    
    %% Calculate Precision & Recall
    
    precision(file_num) = sum(TP) / sum(FP + TP);
    recall(file_num) = sum(TP) / sum(FN + TP);
    specificity(file_num) = sum(TN) / sum(TN + FP);
    f1_score(file_num) = 2*(precision(file_num) .* recall(file_num)) / (precision(file_num) + recall(file_num));
    
    cd('../')
    
    clearvars -except VResults behav_to_validate data_directory f1_score file_num hB_ID precision recall specificity to_validate
end

VResults.Precision = precision;
VResults.Recall = recall;
VResults.Specificity = specificity;
VResults.F1 = f1_score;

VResults.Avg_Precision = nanmean(precision);
VResults.Avg_Recall = nanmean(recall);
VResults.Avg_Specificity = nanmean(specificity);
VResults.Avg_F1 = nanmean(f1_score);

results_filename_ext = strcat(behav_to_validate,'_Validation', '.mat');
save(results_filename_ext, 'VResults')
clearvars -except VResults
msgbox('Validation metrics calculated and saved in data directory');
end