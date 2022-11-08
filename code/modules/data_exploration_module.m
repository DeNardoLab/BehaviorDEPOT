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
disp('Select a BehDEPOT folder (_analyzed) to use for exploration')
analyzed_filepath = uigetdir('', 'Select a BehDEPOT folder (_analyzed) to use for exploration');

disp('Select a hB file (output from convertHumanAnnotations.m)')
[hB_file, hB_path] = uigetfile('','Select a hB file (output from convertHumanAnnotations_BD)');

save_model = 1;

% Ask User which Mode to Use
focused = 0;

[choice_inds, ~] = listdlg('ListString',{'Focused', 'Broad'})

% Run focused mode, if selected
if sum(choice_inds == 1) == 1
    DE_focused(analyzed_filepath, hB_path, hB_file);
end

% Run broad mode, if selected
if sum(choice_inds == 2) == 1
    DE_broad(analyzed_filepath, hB_path, hB_file);
end
end