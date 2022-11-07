%% plotValidationPerformance()

% Function that uses VResults structure to generate performance metrics on
% a per-video basis

function fig = plotValidationPerformance(VResults)
    fig = figure();
    data = [VResults.Precision ; VResults.Recall ; VResults.F1; VResults.Specificity]';
    min_data = min(min(data));
    min_data = 0.98*min_data;
    subplot(2,2,1)
    bar(data(:,1), 'FaceColor', [0.6350 0.0780 0.1840]);
    ylim([min_data 1])
    xlabel('Video Number')
    title('Precision')
    subplot(2,2,2)
    bar(data(:,2), 'FaceColor', [0 0.4470 0.7410]);
    ylim([min_data 1])
    xlabel('Video Number')
    title('Recall')
    subplot(2,2,3)
    bar(data(:,3), 'FaceColor', [0.4940 0.1840 0.5560]);
    ylim([min_data 1])
    xlabel('Video Number')
    title('F1 Score')
    subplot(2,2,4)
    bar(data(:,4), 'FaceColor', [0.9290 0.6940 0.1250]);
    ylim([min_data 1])
    xlabel('Video Number')
    title('Specificity')
    sgtitle([VResults.ValidationBehavior ': Performance by Video'])
end

