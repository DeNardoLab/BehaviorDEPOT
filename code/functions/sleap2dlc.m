%% sleap2dlc
% INPUT: h5path - path to SLEAP h5 file; save2csv - boolean save to csv
% file
% OUTPUT:  cell matrix with SLEAP point tracking data in DLC output format
% created 2022_06_10 ZZ
% modified 2022_06_11 ZZ
% modified 2022_06_16 CG

function sleap2dlc_converted = sleap2dlc(h5_path, save2csv)

disp('Now reading SLEAP file');
%% load data from file (just bodypart tracking info)
node_names = h5read(h5_path, '/node_names');
point_scores = h5read(h5_path, '/point_scores');
tracks = h5read(h5_path,'/tracks');
%instance_scores = h5read(h5_path, '/instance_scores');
%track_names = h5read(h5_path, '/track_names');
%track_occupancy = h5read(h5_path, '/track_occupancy');
%tracking_scores = h5read(h5_path, '/tracking_scores');

%% reformat Body Part tracking and Likelihood (bpl)
bpl = [];

for i = 1:size(tracks,2)
    i_bpl = tracks(:,i,:);
    i_bpl = squeeze(i_bpl);
    i_bpl = [i_bpl, point_scores(:,i)];
    bpl = [bpl, i_bpl];
    i_bpl = [];
end


%% get part names
bplist = {};
for i = 1:length(node_names)
    n = node_names{i};
    bplist = [bplist, n, n, n];
end

%% create labels to recreate DLC output structure
xyl = {'x','y','likelihood'};
xyl = repmat(xyl, [1,length(node_names)]);

topname = repmat({'sleap2dlc'}, [1, length(xyl)]);

frames = [0:length(bpl)-1];
frames = num2cell(frames');
first_col = [{'scorer'}; {'bodyparts'}; {'coords'}; frames];

%% combine everything 
bpl_cell = num2cell(bpl);
out = [topname; bplist; xyl; bpl_cell];
sleap2dlc_converted = [first_col, out];

%% save to csv
    
if save2csv
    writecell(sleap2dlc_converted, 'sleap2dlc_converted.csv');
end

end