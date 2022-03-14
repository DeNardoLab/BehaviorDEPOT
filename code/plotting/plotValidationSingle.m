% plotValidationSingle()
% C.G. 2/24/22
% Contact: cjgabrie@ucla.edu

% Generate plots of average output by performance metrics, using VResults
% structure

function fig = plotValidationSingle(VResults)

fig = figure();
data = [VResults.Avg_Precision, VResults.Avg_Recall, VResults.Avg_F1, VResults.Avg_Specificity];
c_data = [0.6350 0.0780 0.1840; 0 0.4470 0.7410; 0.4940 0.1840 0.5560; 0.9290 0.6940 0.1250];

for i = 1:size(data, 2)
    bar(i, data(i), 'FaceColor', c_data(i,:));
    hold on;
end

xticks([1:size(data,2)]);
min_data = min(min(data));
min_data = 0.98*min_data;
xticklabels({'Precision', 'Recall', 'F1 Score', 'Specificity'})
title([VResults.ValidationBehavior, ' Performance'])
ylim([min_data 1])

end