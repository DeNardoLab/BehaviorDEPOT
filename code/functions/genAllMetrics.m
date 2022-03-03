% shape can be 'r' for row or 'c' for column and affects how each metric is
% stored

function all_metrics = genAllMetrics(Metrics, shape)

if ~exist('shape')
    shape = 'r';
end

all_metrics = struct();
outer_metrics = fieldnames(Metrics);

for i = 1:length(outer_metrics)
    this_metric = Metrics.(outer_metrics{i});
    if isa(this_metric, 'double')
        if size(this_metric, 1) == 1 %Copy metric
            all_metrics.(outer_metrics{i}) = this_metric;
            max_frames = size(this_metric, 2);
        elseif size(this_metric, 1) == 2 %Split into x/y
            all_metrics.([outer_metrics{i} '_X']) = this_metric(1, :);
            all_metrics.([outer_metrics{i} '_Y']) = this_metric(2, :);
        end
        
    elseif isstruct(this_metric)
        inner_metrics = fieldnames(this_metric);
        for ii = 1:length(inner_metrics)
            this_inner_metric = this_metric.(inner_metrics{ii});
            if size(this_inner_metric, 1) == 1 %Copy metric
                all_metrics.([outer_metrics{i}, '_', inner_metrics{ii}]) = this_inner_metric;
            elseif size(this_inner_metric, 1) == 2 %Split into x/y
                all_metrics.([outer_metrics{i}, '_', inner_metrics{ii}, '_X']) = this_inner_metric(1, :);
                all_metrics.([outer_metrics{i}, '_', inner_metrics{ii}, '_Y']) = this_inner_metric(2, :);
            end   
        end
    end
end

field_check = fieldnames(all_metrics);

for i = 1:length(field_check)   
    if strcmpi(shape, 'c')
        all_metrics.(field_check{i}) = all_metrics.(field_check{i})';
    end
    
    if length(all_metrics.(field_check{i})) < max_frames
        all_metrics = rmfield(all_metrics, field_check{i});
    end   
end

try
    all_metrics = rmfield(all_metrics, 'DistanceTravelled_cm');
end

end