%plotTrajectoryMap - plotting function for BehDEPOT

function beh_plot = plotTrajectoryMap(Metrics, frame1, Params, Behavior, analyzed_folder_name)

% Set X/Y Coords
X = Metrics.Location(1,:);
Y = Metrics.Location(2,:);
    
beh_icons = {'ksquare', 'k^','kdiamond', 'kv', 'k+', 'k*', 'kpentagram', 'khexagram'};
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


beh_name = beh_name(logical(beh_check));
beh_cell = beh_cell(logical(beh_check));

% Check if plotBeh preference is on AND that there are behaviors to plot
% (beh_check)
if (Params.plotBeh) && (sum(beh_check)>0)
    for i = 1:length(beh_cell)   % loop through behaviors
        figure;
        I = imshow(frame1);
        set(I, 'AlphaData', 0.4)  % set to 0 if don't want arena image superimposed
        hold on
        title('Behavior Mapping');
        lgnd = [];
    
        if Params.plotSpaceTime
            lgnd = [lgnd, 'location'];
            sz = 1:length(X);
            scatter(X, Y, 5, sz, 'filled');
            colormap('jet');
            colorbar;
            colorbar('Ticks',[100,(length(X)-100)],'TickLabels',{'Start','End'}) 
        elseif Params.plotSpace
            lgnd = [lgnd, 'trajectory'];
            scatter(X, Y, 5, 'filled');
        end        
    
        i_beh_name = string(beh_name(i));  % load behavior name
        i_beh_vec = beh_cell{i}.Vector;   % load behavior vector
        i_beh_loc = Metrics.Location(:,~~i_beh_vec);
        scatter(i_beh_loc(1,:),i_beh_loc(2,:),beh_icons{i});
        lgnd = [lgnd, i_beh_name];
    
        if Params.do_roi
            for i = 1:length(Params.roi)
               plot(polyshape(Params.roi{i}), 'FaceAlpha', 0.1);
               lgnd = [lgnd, strcat('ROI #',string(i))];
            end
        end
    
        legend(lgnd);
        beh_plot = gcf;   
        cd(analyzed_folder_name)
        savename = strcat(i_beh_name, ' Map');
        savefig(beh_plot, (savename));
        close;
    end
else
    figure;
    I = imshow(frame1);
    set(I, 'AlphaData', 0.5)  % set to 0 if don't want arena image superimposed
    hold on
    title('Trajectory Mapping');

    if Params.plotSpaceTime
        % Plot spatiotemporal trajectory without behavior
        lgnd = ['location'];
        sz = 1:length(X);
        scatter(X, Y, 5, sz, 'filled');
        colormap('jet');
        colorbar;
        colorbar('Ticks',[100,(length(X)-100)],'TickLabels',{'Start','End'})
        savename = strcat('Spatiotemporal Trajectory Map');
    else
        % Plot spatial trajectory
        lgnd = ['trajectory'];
        scatter(X, Y, 5, 'filled');
        savename = strcat('Spatial Trajectory Map');
    end   

    if Params.do_roi
        for i = 1:length(Params.roi)
           plot(polyshape(Params.roi{i}), 'FaceAlpha', 0.1);
           lgnd = [lgnd, strcat('ROI #',string(i))];
        end
    end

    legend(lgnd);
    sptm_plot = gcf;
    cd(analyzed_folder_name)

    savefig(sptm_plot, (savename));
end

end


