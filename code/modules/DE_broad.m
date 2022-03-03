% Data Exploration Module - Broad
% C.G. 2/24/22
% Contact: cjgabrie@ucla.edu

function DE_broad(analyzed_filepath, hB_path, hB_file)

% Load BD data
cd(analyzed_filepath)
to_load = dir('*.mat');

for i = 1:length(to_load)
    load(to_load(i).name)
end

% Load hB file
load([hB_path, hB_file])

hB_list = fieldnames(hBehavior);
hB_behavs = string();
count = 0;

for i = 1:length(hB_list)
    if isstruct(hBehavior.(hB_list{i}))
        count = count + 1; 
        hB_behavs(count) = hB_list(i);
    end
end

% Prompt user to choose behavior from hB file
hB_ind = listdlg('PromptString', {'Select behavior to examine.'}, 'ListString', hB_behavs, 'SelectionMode', 'single');
behav = hB_behavs(hB_ind);
behav_vector = logical(hBehavior.(behav).Vector);
cmp_vector = ~behav_vector;

% Generate all_metrics and convert to table/array format
all_metrics = genAllMetrics(Metrics, 'c');
metric_labels = fieldnames(all_metrics);

metric_table = struct2table(all_metrics);
metric_array = table2array(metric_table);
metric_array_z = zscore(metric_array);
metric_table_z = array2table(metric_array_z);

%% Create GLM with all Metrics
deGLM = fitglm(metric_array, behav_vector, 'Distribution', 'binomial');
coef_table = deGLM.Coefficients;
coef = coef_table.Estimate;

%% Get Rid of Bad Metrics from Metric_array
to_remove = -1 < coef < 1;
metric_array(:,to_remove) = [];
metric_labels(to_remove) = [];

%% Allow user to manually remove metrics, if desired
tf = 1;

while tf
    [remove_inds, tf] = listdlg('PromptString', {'(Optional) Select metrics to remove from model.',...
                      'Select "Continue" when finished removing metrics'}, 'ListString', metric_labels,...
                      'OKString', 'Remove Metric(s)', 'CancelString', 'Continue');
    metric_array(:,remove_inds) = [];
    metric_labels(remove_inds) = [];
end

%% Run New GLM
deGLM = fitglm(metric_array, behav_vector, 'Distribution', 'binomial')
coef_table = deGLM.Coefficients;
coef = coef_table.Estimate;

%% Generate Predictions based on GLM / Assess Performance
% Generate ranked order based on coefficients
[ranked, old_inds] = sort(coef(2:end));
ranked_list = [metric_labels(old_inds)];

%% Save GLM Equation & Relevant Data
save_path = Params.basedir;
cd(save_path)
mkdir('DE_Results')
cd('DE_Results')
mkdir('Broad')
cd('Broad')
save('GLM Model', 'deGLM')
save('ranked_list', 'ranked_list')
save('coefficient_table', 'coef_table')

end