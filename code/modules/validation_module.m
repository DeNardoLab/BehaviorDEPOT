% Validation Module
% C.G. 2/24/22
% Contact: cjgabrie@ucla.edu

% SINGLE:
% Select directory containing 1 BehaviorDEPOT output folder and 1 associated hB file

% BATCH:
% Required directory (dir) structure:  grandparent \ dir1, dir2, dirN...
% dirN contains hB file and _analyzed folder with Behavior file

function validation_module()

%% Initialization - Required Inputs
hB_ID = 'hB*'; %Identifier for human annotation files
analyzed_ID = '*_analyzed';
disp('Select directory containing folders with paired hB files (output from convertHumanAnnotations) and BehDEPOT "_analyzed" folders')
data_directory = uigetdir('','Select directory containing data folders with hB and Behavior files');
homedir = pwd;

%% Check if single or batch mode based on dir contents

cd(data_directory)

% Search input directory
BD_search = dir('**/*_analyzed');
hB_search = dir('**/hB_*');

BD_paths = {BD_search.folder};
hB_paths = {hB_search.folder};

% Find matching directories
BD_dirs = unique(BD_paths);
hB_dirs = unique(hB_paths);

BD_match = zeros(size(BD_dirs));

for i = 1:length(BD_dirs)
   match_test = strcmpi(BD_dirs(i), hB_dirs);
   if sum(match_test) == 1
       BD_match(i) = 1;
   end
end

% Initialize counter & file struct
c = 0;
to_validate = struct();

% Match up files
for i = find(BD_match)
    this_path = BD_dirs(i);
    BD_ind = strcmp(BD_paths, this_path);
    hB_ind = strcmp(hB_paths, this_path);

    if sum(BD_ind) == 1 && sum(hB_ind) == 1
        c = c + 1;
        to_validate(c).BDfile = BD_search(BD_ind).name;
        to_validate(c).hBfile = hB_search(hB_ind).name;
        to_validate(c).path = this_path;
    end
end

%% Validation
%to_validate = prepBatch(data_directory);

for file_num = 1:length(to_validate)
    % cd into correct directory
    d_folder = to_validate(file_num).path{:};
    cd(d_folder)
    
    ref_file = to_validate(file_num).hBfile;
    load(ref_file);

    comp_dir = to_validate(file_num).BDfile;

    cd(comp_dir)
    load('Behavior.mat')
    cd('../')
    
    VResults.ReferenceFiles(file_num, :) = string(ref_file);
    VResults.ComparisonFiles(file_num, :) = string(comp_dir);
    
    % Identify relevant data from Behavior and hBehavior
    ref_fields = fieldnames(hBehavior);
    comp_fields = fieldnames(Behavior);
    
    if file_num == 1
        [s,v] = listdlg('PromptString','Select behavior to validate:',...
        'SelectionMode','single','ListString',comp_fields);
        behav_to_validate = (comp_fields{s});
    end
    
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
    TP = zeros(size(ref_data));
    TN = zeros(size(ref_data));
    
    for ii = 1:total_frames
        if (error_matrix(ii) == 0) && (ref_data(ii) == 1)
            TP(ii) = 1;
        elseif (error_matrix(ii) == 0) && (ref_data(ii) == 0)
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
    
    clearvars -except VResults behav_to_validate data_directory f1_score file_num hB_ID analyzed_ID precision recall specificity to_validate
end

VResults.ValidationBehavior = behav_to_validate;
VResults.Precision = precision;
VResults.Recall = recall;
VResults.Specificity = specificity;
VResults.F1 = f1_score;

VResults.Avg_Precision = nanmean(precision);
VResults.Avg_Recall = nanmean(recall);
VResults.Avg_Specificity = nanmean(specificity);
VResults.Avg_F1 = nanmean(f1_score);

% Change to data directory and make VResults folder
cd(data_directory)
results_folder = 'ValidationResults';
mkdir(results_folder)
cd(results_folder)

% Plot and Save Figures
if length(to_validate) > 1
    fig1 = plotValidationPerformance(VResults);
    saveas(fig1, 'PerformanceByVideo.jpg')
    close(fig1)
    
    fig2 = plotValidationAvg(VResults);
    saveas(fig2, 'AvgPerformance.jpg')
    close(fig2) 
else
    fig1 = plotValidationSingle(VResults);
    saveas(fig1, 'Performance.jpg')
    close(fig1)
end

results_filename_ext = strcat(behav_to_validate,'_Validation', '.mat');
save(results_filename_ext, 'VResults')
cd(data_directory)
clearvars -except VResults
disp('Validation metrics calculated and saved in data directory');
end