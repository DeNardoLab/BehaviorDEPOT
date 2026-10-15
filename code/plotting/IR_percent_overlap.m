%% Plot percent overlap via heatmap

function IR_percent_overlap(IR_Results, behavior, save_fig)

    figure()
    heatmap(IR_Results.names, IR_Results.names, IR_Results.(behavior).percent_overlap)
    title('Percent Overlap Between Raters')
    
    if ~exist('save_fig', 'var')
        save_fig = 0;
    end
    
    if save_fig == 1
        saveas(gcf, fullfile(IR_Results.working_directory, 'IR_PercentOverlap.png'))
    end
end
