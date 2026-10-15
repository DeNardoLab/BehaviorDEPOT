%% Calculate Performance of Binary Reference and Comparison Data -- CG 12/20/21
% Inputs: 1) ref_data: binary vector with reference labels (size: 1xN)
%         2) comp_data: binary vector with labels for comparison (size: 1xN)

function [precision, recall, f1_score, specificity, counts] = calculatePerformance(ref_data, comp_data)

% Compare data by accessing behavior vectors
ref_data = ref_data(:)';
comp_data = comp_data(:)';

if numel(ref_data) ~= numel(comp_data)
    error('BehaviorDEPOT:calculatePerformance:InputSizeMismatch', ...
        'Reference and comparison vectors must have the same number of elements.');
end

TP = (ref_data == 1) & (comp_data == 1);
TN = (ref_data == 0) & (comp_data == 0);
FP = (ref_data == 0) & (comp_data == 1);
FN = (ref_data == 1) & (comp_data == 0);

%% Calculate Precision & Recall

precision = sum(TP) / sum(FP + TP);
recall = sum(TP) / sum(FN + TP);
specificity = sum(TN) / sum(TN + FP);
f1_score = 2*(precision .* recall / (precision + recall));

counts.TruePositives = sum(TP);
counts.TrueNegatives = sum(TN);
counts.FalsePositives = sum(FP);
counts.FalseNegatives = sum(FN);

end
