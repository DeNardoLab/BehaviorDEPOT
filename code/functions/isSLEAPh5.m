function true = isSLEAPh5(tracking_file)

% Intialize outcome variable and read info from h5 file
true = 0;
info = h5info(tracking_file);

% Look for SLEAP h5 unique identifier: 'instance_Scores' top layer header
if isequal(info.Datasets(1).Name, 'instance_Scores')
    true = 1;
end
end