function bouts_plot = plot_bouts(Behavior, analyzed_folder_name)
    
    beh_name = fieldnames(Behavior);
    beh_cell = struct2cell(Behavior);
    numplots = length(beh_cell);
    framesz = length(beh_cell{1}.Vector);

    for i = 1:length(beh_cell)   % loop through behaviors    
        i_bouts = beh_cell{i}.Bouts'; 
        subplot(numplots,1,i);
        hold on
        ax = gca;
        ax.XLim(1) = 0;
        ax.XLim(2) = framesz;
        yticks([0.5])
        yticklabels({beh_name{i}});
        if i == 1
            title('Behavior Bouts');
            xlabel('Frame #');
        end
        if ~isempty(i_bouts)
            i_bouts = [i_bouts; i_bouts(2,:); i_bouts(1,:)];
            y = ones(size(i_bouts)) .* [0;0;1;1];
            patch(i_bouts,y,'k');
        end      
    end
     
    bouts_plot = gcf;
    cd(analyzed_folder_name)
    savefig(bouts_plot, 'Behavior Bouts');

end

