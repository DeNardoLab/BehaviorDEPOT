%Plot Rater Percent Agreement
% Plots the number of raters who said freezing was present at x frame
% divided by the total number of raters

function IR_percent_agreement(IR_Results, behavior, save_fig)

    figure()
    data = IR_Results.(behavior).agreement' / length(IR_Results.names);
    imagesc(data)
    colorbar
    title('InterRater Percent Agreement')
    set(gca, 'ytick', [])
    xlabel('Frame')
    
    if ~exist('save_fig', 'var')
        save_fig = 0;
    end
    
    if save_fig == 1
        saveas(gcf, 'IR_PercentAgreement.png')
    end
    
end