% importSLEAPTracking
% PURPOSE: import data from SLEAP h5 files in BehaviorDEPOT format

function [data, Params] = importSLEAPTracking(Params)

%% Load data from SLEAP h5
cd(Params.basedir);
disp('Reading tracking file')

node_names = h5read(Params.tracking_file, '/node_names');
tracks = h5read(Params.tracking_file,'/tracks');

%% Reformat Body Part tracking and Likelihood (bpl)
% Initialize variables
data = zeros(size(tracks,2)*3, size(tracks,1));
count = 1;

for i = 1:size(tracks,2)
    data(count:count+1,:) = squeeze(tracks(:,i,:))';
    data(count+2,:) = NaN;
    count = count+3;
end

%% Get part names
node_names = deblank(node_names);
part_names = cellstr(node_names');

% Remove characters from names that may break the code
part_names = cleanText(part_names);
Params.part_names = part_names;

disp('SLEAP H5 Loaded');

end