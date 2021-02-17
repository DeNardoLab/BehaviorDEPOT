%prepBatch

%INPUT: video_directory
%OUTPUT: video_folder_list (list of directories containing video and CSV/H5
%files to analyze

%FUNCTION: Generate a list of videos for batch analysis

function video_folder_list = prepBatch(video_directory)
    cd(video_directory)
    directory_contents = dir;
    directory_contents(1:2) = [];
    ii = 0;

    for i = 1:size(directory_contents, 1)
        current_structure = directory_contents(i);
        if current_structure.isdir
            ii = ii + 1;
            video_folder_list(ii) = string(current_structure.name);
            disp([num2str(i) ' directory loaded'])
        end
    end
end