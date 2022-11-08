%% Plot Precision/Recall

function IR_performance(IR_Results, behavior, save_fig)
    data = [IR_Results.(behavior).precision, IR_Results.(behavior).recall, IR_Results.(behavior).specificity, IR_Results.(behavior).f1_score];
    heatmap(IR_Results.names, {'Precision', 'Recall', 'Specificity', 'F1 Score'}, data')
    title({'InterRater Performance'; strcat(string('Reference = '), IR_Results.reference_name)})
    
    if ~exist('save_fig', 'var')
        save_fig = 0;
    end
    
    if save_fig == 1
        saveas(gcf, 'IR_Performance.png')
    end
end