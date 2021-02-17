
function beh_plot = plotTrajectoryMap(Metrics, frame1, Params, Behavior, analyzed_folder_name)
    X = Metrics.Location(1,:);
    Y = Metrics.Location(2,:);
    if Params.plotBeh  % if plotting behavior, loop through behaviors and make individual figures
        beh_icons = {'ksquare', 'k^','kdiamond', 'kv', 'k+', 'k*', 'kpentagram', 'khexagram'};
        beh_name = fieldnames(Behavior);
        beh_cell = struct2cell(Behavior);

        for i = 1:length(beh_cell)   % loop through behaviors
                close;
                figure;
                I = imshow(frame1);
                set(I, 'AlphaData', 0.2)  % set to 0 if don't want arena image superimposed
                hold on
                title('Behavior Mapping');
                leg = [];
                
            if Params.plotSpaceTime
                leg = [leg, 'location'];
                sz = 1:length(X);
                scatter(X, Y, 5, sz, 'filled');
                colormap('jet');
                colorbar;
                colorbar('Ticks',[100,(length(X)-100)],'TickLabels',{'Start','End'}) 
            elseif Params.plotSpace
                leg = [leg, 'trajectory'];
                scatter(X, Y, 5, 'filled');
            end        
            
                i_beh_name = string(beh_name(i));  % load behvavior name
                i_beh_vec = beh_cell{i}.Vector;   % load behavior vector
                i_beh_loc = Metrics.Location(:,~~i_beh_vec);
                scatter(i_beh_loc(1,:),i_beh_loc(2,:),beh_icons{i});
                leg = [leg, i_beh_name];
    
            if Params.do_roi
            for i = 1:length(Params.roi)
               plot(polyshape(Params.roi{i}), 'FaceAlpha', 0.1);
               leg = [leg, strcat('ROI #',string(i))];
            end
            end
            
            legend(leg);
            beh_plot = gcf;   
            cd(analyzed_folder_name)
            savename = strcat(i_beh_name, ' Map');
            savefig(beh_plot, (savename));
        end
            
           
            
    elseif Params.plotSpaceTime
        figure;
        I = imshow(frame1);
        set(I, 'AlphaData', 0.2)  % set to 0 if don't want arena image superimposed
        hold on
        title('Behavior Mapping');
        leg = [];

        leg = [leg, 'location'];
        sz = 1:length(X);
        scatter(X, Y, 5, sz, 'filled');
        colormap('jet');
        colorbar;
        colorbar('Ticks',[100,(length(X)-100)],'TickLabels',{'Start','End'}) 
        if Params.do_roi
            for i = 1:length(Params.roi)
               plot(polyshape(Params.roi{i}), 'FaceAlpha', 0.1);
               leg = [leg, strcat('ROI #',string(i))];
            end
        end
        
        legend(leg);
        beh_plot = gcf;   
        cd(analyzed_folder_name)
        savename = 'Behavior Map';
        savefig(beh_plot, (savename));
        
    elseif Params.plotSpace
        figure;
        I = imshow(frame1);
        set(I, 'AlphaData', 0.2)  % set to 0 if don't want arena image superimposed
        hold on
        title('Behavior Mapping');
        leg = [];
        leg = [leg, 'trajectory'];
        scatter(X, Y, 5, 'filled');
       if Params.do_roi
            for i = 1:length(Params.roi)
               plot(polyshape(Params.roi{i}), 'FaceAlpha', 0.1);
               leg = [leg, strcat('ROI #',string(i))];
            end
       end
       
       legend(leg);
       beh_plot = gcf;   
       cd(analyzed_folder_name)
       savename = 'Behavior Map';
       savefig(beh_plot, (savename));
    end           
end


