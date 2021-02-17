% Data Exploration Module

% PURPOSE:

% INPUTS:
    % 1. BehaviorDEPOT '_analyzed' filepath
    % 2. Name of 1 or 2 metrics from the Metrics structure
    % 3. Filepath to associated hB file (or auto-detect)
    % 4. Behavior from hB to test

% OUTPUTS: 
    % 1. Figure: Histograms Labeled by Behavior
    % 2. Figure: Boxplots of Z-Scored Data
    % 3. Figure: Probability Estimates from GLM 
    % 4. Table: Calculated Results and Statistics

function data_exploration_module()
%% Initialize Required Inputs

% Set input variables
analyzed_filepath = uigetdir('', 'Select a BehDEPOT folder (_analyzed) to use for exploration');
[hB_file, hB_path] = uigetfile('','Select a hB file (output from convertHumanAnnotations.m)');
%save_filepath = ''; 
save_model = 1;

%% Main Script
% Load in data from filepath
cd(analyzed_filepath)
to_load = dir('*.mat');

for i = 1:length(to_load)
    load(to_load(i).name)
end

% Prompt user to choose Metrics
available_metrics = fieldnames(Metrics);

ind1 = listdlg('PromptString', {'Select 1st metric to test.'}, 'ListString', available_metrics, 'SelectionMode','single');
if isstruct(Metrics.(available_metrics{ind1}))
    inner_metrics1 = fieldnames(Metrics.(available_metrics{ind1}));
    inner_ind1 = listdlg('PromptString', {'Select metric from ' + string(available_metrics{ind1})}, 'ListString', inner_metrics1, 'SelectionMode','single');
    m1 = [string(strcat(inner_metrics1{inner_ind1}, available_metrics{ind1}))];
    m1_data = Metrics.(available_metrics{ind1}).(inner_metrics1{inner_ind1});
else
    m1 = available_metrics(ind1);
    m1_data = Metrics.(m1{1});
end

ind2 = listdlg('PromptString', {'Select 2nd metric to test.'}, 'ListString', available_metrics, 'SelectionMode', 'single');
if isstruct(Metrics.(available_metrics{ind2}))
    inner_metrics2 = fieldnames(Metrics.(available_metrics{ind2}));
    inner_ind2 = listdlg('PromptString', {'Select metric from ' + string(available_metrics{ind2})}, 'ListString', inner_metrics2, 'SelectionMode','single');
    m2 = [string(strcat(inner_metrics2{inner_ind2}, available_metrics{ind2}))];
    m2_data = Metrics.(available_metrics{ind2}).(inner_metrics2{inner_ind2});
else
    m2 = available_metrics(ind2);
    m2_data = Metrics.(m2{1});
end

% Load data from hB file
% cd(hB_filepath)
% hB_search = dir('hB*');
% if size(hB_search, 1) == 1
%     load(hB_search.name)
% end

load([hB_path, '\', hB_file])

% Extract behaviors from hB struct
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
behav_vector = logical(hBehavior.(behav).Vector)';
cmp_vector = ~behav_vector;

% Split hB data in behavior / not-behavior datasets
m1_behav = m1_data(behav_vector);
m1_cmp = m1_data(cmp_vector);
m2_behav = m2_data(behav_vector);
m2_cmp = m2_data(cmp_vector);

%% Output Calculations
%% Calculate mean & SD for raw and Z-scored data sets

m1_mean = nanmean(m1_data);
m1_SD = nanstd(m1_data);
m1_behav_mean = nanmean(m1_behav);
m1_cmp_mean = nanmean(m1_cmp);
m1_behav_SD = nanstd(m1_behav);
m1_cmp_SD = nanstd(m1_cmp);
m1_Z = zscore(m1_data);
m1_behav_Z = m1_Z(behav_vector);
m1_cmp_Z = m1_Z(cmp_vector);
m1_behav_Z_mean = nanmean(m1_behav_Z);
m1_cmp_Z_mean = nanmean(m1_cmp_Z);
m1_behav_Z_SD = nanstd(m1_behav_Z);
m1_cmp_Z_SD = nanstd(m1_cmp_Z);

m2_mean = nanmean(m2_data);
m2_SD = nanstd(m2_data);
m2_behav_mean = nanmean(m2_behav);
m2_cmp_mean = nanmean(m2_cmp);
m2_behav_SD = nanstd(m2_behav);
m2_cmp_SD = nanstd(m2_cmp);
m2_Z = zscore(m2_data);
m2_behav_Z = m2_Z(behav_vector);
m2_cmp_Z = m2_Z(cmp_vector);
m2_behav_Z_mean = nanmean(m2_behav_Z);
m2_cmp_Z_mean = nanmean(m2_cmp_Z);
m2_behav_Z_SD = nanstd(m2_behav_Z);
m2_cmp_Z_SD = nanstd(m2_cmp_Z);

%% Randomly Subset Data from Larger Distribution to Match Smaller Distribution

behav_inds = find(behav_vector);
cmp_inds = find(cmp_vector);
subset = length(behav_inds) > length(cmp_inds);

if subset
    % Subset behav inds to match number of cmp inds
    behav_subset_inds = randperm(length(behav_inds), length(cmp_inds));
    m1_behav_Z_subset = m1_behav_Z(behav_subset_inds);
    m2_behav_Z_subset = m2_behav_Z(behav_subset_inds);
else
    % Subset cmp inds to match number of behav inds
    cmp_subset_inds = randperm(length(cmp_inds), length(behav_inds));
    m1_cmp_Z_subset = m1_cmp_Z(cmp_subset_inds);
    m2_cmp_Z_subset = m2_cmp_Z(cmp_subset_inds);
end

%% FIGURE 1: Comparative Histograms Labeled by Behavior
if subset
    f1 = figure(1);
    subplot(2,1,1)
    histogram(m1_behav_Z_subset, 'EdgeColor', 'blue', 'FaceColor', 'blue', 'FaceAlpha', 0.5)
    title([m1, ': Z Behavior v Non-Behavior Frames']);
    hold on;
    histogram(m1_cmp_Z, 'EdgeColor', 'red', 'FaceColor', 'red', 'FaceAlpha', 0.2)
    legend('Behavior','Non-Behavior')
    subplot(2,1,2)
    histogram(m2_behav_Z_subset, 'EdgeColor', 'blue', 'FaceColor', 'blue', 'FaceAlpha', 0.5)
    title([m2, ': Z Behavior v Non-Behavior Frames']);
    hold on;
    histogram(m2_cmp_Z, 'EdgeColor', 'red', 'FaceColor', 'red', 'FaceAlpha', 0.2)
    legend('Behavior','Non-Behavior')
else
    f1 = figure(1);
    subplot(2,1,1)
    histogram(m1_behav_Z, 'EdgeColor', 'blue', 'FaceColor', 'blue', 'FaceAlpha', 0.5)
    title([m1, ': Z Behavior v Non-Behavior Frames']);
    hold on;
    histogram(m1_cmp_Z_subset, 'EdgeColor', 'red', 'FaceColor', 'red', 'FaceAlpha', 0.2)
    legend('Behavior','Non-Behavior')
    subplot(2,1,2)
    histogram(m2_behav_Z, 'EdgeColor', 'blue', 'FaceColor', 'blue', 'FaceAlpha', 0.5)
    title([m2, ': Z Behavior v Non-Behavior Frames']);
    hold on;
    histogram(m2_cmp_Z_subset, 'EdgeColor', 'red', 'FaceColor', 'red', 'FaceAlpha', 0.2)
    legend('Behavior','Non-Behavior')
end

%% FIGURE 2: Comparative Z-Scored Boxplots

if subset
    f2 = figure(2);
    data = [m1_Z, m1_behav_Z_subset, m1_cmp_Z]';
    g1 = repmat({'All'},length(m1_Z),1);
    g2 = repmat({'Behavior'},length(m1_behav_Z_subset),1);
    g3 = repmat({'Non-Behavior'},length(m1_cmp_Z),1);
    g = [g1; g2; g3];
    subplot(1,2,1)
    boxplot(data, g)
    title([m1{1}, ': Z Score Distributions'])

    data = [m2_Z, m2_behav_Z_subset, m2_cmp_Z]';
    g1 = repmat({'All'},length(m2_Z),1);
    g2 = repmat({'Behavior'},length(m2_behav_Z_subset),1);
    g3 = repmat({'Non-Behavior'},length(m2_cmp_Z),1);
    g = [g1; g2; g3];
    subplot(1,2,2)
    boxplot(data, g)
    title([m2{1}, ': Z Score Distributions'])
else
    f2 = figure(2);
    data = [m1_Z, m1_behav_Z, m1_cmp_Z_subset]';
    g1 = repmat({'All'},length(m1_Z),1);
    g2 = repmat({'Behavior'},length(m1_behav_Z),1);
    g3 = repmat({'Non-Behavior'},length(m1_cmp_Z_subset),1);
    g = [g1; g2; g3];
    subplot(1,2,1)
    boxplot(data, g)
    title([m1{1}, ': Z Score Distributions'])

    data = [m2_Z, m2_behav_Z, m2_cmp_Z_subset]';
    g1 = repmat({'All'},length(m2_Z),1);
    g2 = repmat({'Behavior'},length(m2_behav_Z),1);
    g3 = repmat({'Non-Behavior'},length(m2_cmp_Z_subset),1);
    g = [g1; g2; g3];
    subplot(1,2,2)
    boxplot(data, g)
    title([m2{1}, ': Z Score Distributions'])
end

%% Compare Mahalanobis Distance of Behavior and Cmp Groups to All Data

if subset
    m1_behav_mahal = mahal(m1_behav_Z_subset', m1_data');
    m2_behav_mahal = mahal(m2_behav_Z_subset', m2_data');
    m1_cmp_mahal = mahal(m1_cmp_Z', m1_data');
    m2_cmp_mahal = mahal(m2_cmp_Z', m2_data');
else
    m1_behav_mahal = mahal(m1_behav_Z', m1_data');
    m2_behav_mahal = mahal(m2_behav_Z', m2_data');
    m1_cmp_mahal = mahal(m1_cmp_Z_subset', m1_data');
    m2_cmp_mahal = mahal(m2_cmp_Z_subset', m2_data');
end

m1_behav_mahal_mean = mean(m1_behav_mahal);
m2_behav_mahal_mean = mean(m2_behav_mahal);
m1_cmp_mahal_mean = mean(m1_cmp_mahal);
m2_cmp_mahal_mean = mean(m2_cmp_mahal);

%% FIGURE 3: Behavior Probability Estimates from GLM

% Generate generalized linear model using selected metrics
tbl = table(abs(m1_data)', abs(m2_data)', behav_vector');
mdl_spec = 'Var3 ~ Var1*Var2 - Var1:Var2';
mdl = fitglm(tbl, mdl_spec, 'Distribution', 'binomial')

m1_vals_to_test = [m1_mean-2*m1_SD, m1_mean-m1_SD, m1_mean, m1_mean+m1_SD, m1_mean+2*m1_SD];
m2_vals_to_test = [m2_mean-2*m2_SD, m2_mean-m2_SD, m2_mean, m2_mean+m2_SD, m2_mean+2*m2_SD];
predictions = zeros(length(m1_vals_to_test), length(m2_vals_to_test));

for i1 = 1:length(m1_vals_to_test)
    for i2 = 1:length(m2_vals_to_test)
        predictions(i1, i2) = predict(mdl, [m1_vals_to_test(i1), m2_vals_to_test(i2)]);
    end
end

f3 = figure(3);
heatmap({'Mean-2SD', 'Mean-1SD', 'Mean', 'Mean+1SD', 'Mean+2SD'}, {'Mean-2SD', 'Mean-1SD', 'Mean', 'Mean+1SD', 'Mean+2SD'}, predictions)
title('Estimated Probability of Behavior')
ylabel(m1)
xlabel(m2)

%% TABLE 1: Calculated Results for chosen Metrics by Behavior/Non-Behavior Group 

m1_b = [m1, ' (Behavior)'];
m1_c = [m1, ' (Non-Behavior)'];
m2_b = [m2, ' (Behavior)'];
m2_c = [m2, ' (Non-Behavior)'];

Name = {m1_b, m1_c, m2_b, m2_c}';
Mean = [m1_behav_mean, m1_cmp_mean, m2_behav_mean, m2_cmp_mean]';
SD = [m1_behav_SD, m1_cmp_SD, m2_behav_SD, m2_cmp_SD]';
Z_Mean = [m1_behav_Z_mean, m1_cmp_Z_mean, m2_behav_Z_mean, m2_cmp_Z_mean]'; 
Z_SD = [m1_behav_Z_SD, m1_cmp_Z_SD, m2_behav_Z_SD, m2_cmp_Z_SD]';
Mahalanobis = [m1_behav_mahal_mean, m1_cmp_mahal_mean, m2_behav_mahal_mean, m2_cmp_mahal_mean]';

results_table = table(Name, Mean, SD, Z_Mean, Z_SD, Mahalanobis);
%% Save Figures and Table

save_path = Params.basedir;
cd(save_path)
mkdir('DE_Results')
cd('DE_Results')
if save_model
    save('GLM Model', 'mdl')
end

savefig(f1, 'Behavior_Histograms')
savefig(f2, 'Z-Score_Boxplots')
savefig(f3, 'GLM_Probability_Estimates')
writetable(results_table, 'Results')
end