function bouts_plot = plotBouts(Behavior, analyzed_folder_name)
    
beh_name = fieldnames(Behavior);
beh_cell = struct2cell(Behavior);
beh_check = zeros(size(beh_cell));

for i = 1:size(beh_cell, 1)
   to_check = fieldnames(beh_cell{i});
   % Check if structs have Bouts and Vector fields, use logic (inds are
   % mutually exclusive)
   check_sum = sum(strcmpi(to_check, 'Bouts') | strcmpi(to_check, 'Vector'));
   if check_sum == 2
       beh_check(i) = 1;
   end
end

if sum(beh_check) > 0
    beh_name = beh_name(logical(beh_check));
    beh_cell = beh_cell(logical(beh_check));
    
    numplots = length(beh_cell);
    framesz = length(beh_cell{1}.Vector);
    
    if size(beh_cell, 2) > 0
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
        close;
    end
end
end

