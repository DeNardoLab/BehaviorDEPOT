function list_of_dirs = dirDirs(dir_of_dirs_path)

d = dir(dir_of_dirs_path);
d(1:2) = [];
dir_check = [d.isdir];

list_of_dirs = {};
c = 0;

for i = find(dir_check)
    data_path = fullfile(d(i).folder, d(i).name);

    c = c+1;
    list_of_dirs{c} = data_path;
end


end
