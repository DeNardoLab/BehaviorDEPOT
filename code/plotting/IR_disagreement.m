%% Rater Disagreement Score
% Values indicate number of other raters that disagreed at each frame in
% video

function IR_disagreement(IR_Results, behavior, save_fig)
    figure()
    data = IR_Results.(behavior).disagreement;
    imagesc(data)
    title('Rater Disagreement Score')
    yticks([1:length(IR_Results.names)])
    yticklabels(IR_Results.names)
    xlabel('Frame')
    ylabel('Rater')
    colorbar

    if ~exist('save_fig', 'var')
        save_fig = 0;
    end
    
    if save_fig == 1
        saveas(gcf, 'IR_Disagreement.png')
    end
end