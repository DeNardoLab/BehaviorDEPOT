function [data, Params] = importSLEAPTracking(Params)
    save_as_csv = 1;
    data = [];
    cd(Params.basedir);
    disp('Reading tracking file')
    data = sleap2dlc(Params.tracking_file, save_as_csv);
    disp('SLEAP h5 Loaded');
    % remove characters from names that may break the code
    part_names = cleanText(part_names);
    Params.part_names = part_names;
end