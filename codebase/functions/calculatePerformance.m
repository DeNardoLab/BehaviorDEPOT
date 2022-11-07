%% Calculate Performance of Binary Reference and Comparison Data -- CG 12/20/21
% Inputs: 1) ref_data: binary vector with reference labels (size: 1xN)
%         2) comp_data: binary vector with labels for comparison (size: 1xN)

function [precision, recall, f1_score, specificity] = calculatePerformance(ref_data, comp_data)

% Compare data by accessing behavior vectors
error_matrix = ref_data - comp_data;
total_frames = length(error_matrix);

% Sort data into TP, TN, FP, FN   
TP = zeros(1, total_frames);
TN = zeros(1, total_frames);

for i = 1:total_frames
    if (error_matrix(i) == 0) & (ref_data(i) == 1)
        TP(i) = 1;
    elseif (error_matrix(i) == 0) & (ref_data(i) == 0)
        TN(i) = 1;
    end
end

FP = error_matrix == 1;
FN = error_matrix == -1;

%% Calculate Precision & Recall

precision = sum(TP) / sum(FP + TP);
recall = sum(TP) / sum(FN + TP);
specificity = sum(TN) / sum(TN + FP);
f1_score = 2*(precision .* recall / (precision + recall));

end