%% Batch Pull From Misc

%% Batch Move to Misc

% INPUT: directory of data directories, each containing files and a 'Misc'
% folder (will create if none exists)

% PURPOSE: rapidly move files from each data directory into the respective
% 'Misc' folder based on search_terms variable

function batch_misc2data(search_terms)

basedir = pwd;
batch_dir = uigetdir('Select batch directory');
data_dirs = dirDirs(batch_dir);

for d = 1:length(data_dirs)
    cd(data_dirs{d})
    cd('Misc')
    for i = 1:length(search_terms)
        dir_search = dir(search_terms{i});
        for j = 1:size(dir_search, 1)
            movefile(dir_search(j).name, '..')
        end
    end
end

cd(basedir)

end