function list_of_dirs = dirDirs(dir_of_dirs_path)

baseDir = pwd;

cd(dir_of_dirs_path)

d = dir;
d(1:2) = [];
dir_check = [d.isdir];

list_of_dirs = {};
c = 0;

for i = find(dir_check)
    data_path = [d(i).folder, addSlash(), d(i).name];

    c = c+1;
    list_of_dirs{c} = data_path;
end


end