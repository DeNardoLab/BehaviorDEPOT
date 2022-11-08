%removes non alpha-numeric characters
%INPUT: cell array
%OUTPUT: cell array with non alpha-numeric characters removed via strrep

function textcells = cleanText(textcells)

    for i = 1:length(textcells)  % remove inappropriate characters 
        textcells{i} = strrep(textcells{i},' ','');
        textcells{i} = strrep(textcells{i},'-','');
        textcells{i} = strrep(textcells{i},'/','');
        textcells{i} = strrep(textcells{i},'\','');
        textcells{i} = strrep(textcells{i},'+','');
        textcells{i} = strrep(textcells{i},'=','');
        textcells{i} = strrep(textcells{i},'*','');
        textcells{i} = strrep(textcells{i},',','');
        textcells{i} = strrep(textcells{i},'~','');
        textcells{i} = strrep(textcells{i},'`','');
        textcells{i} = strrep(textcells{i},'@','');
        textcells{i} = strrep(textcells{i},'#','');
        textcells{i} = strrep(textcells{i},'$','');
        textcells{i} = strrep(textcells{i},'%','');
        textcells{i} = strrep(textcells{i},'^','');
        textcells{i} = strrep(textcells{i},'&','');
        textcells{i} = strrep(textcells{i},'(','');
        textcells{i} = strrep(textcells{i},')','');
        textcells{i} = strrep(textcells{i},'|','');
        textcells{i} = strrep(textcells{i},'<','');
        textcells{i} = strrep(textcells{i},'>','');
        textcells{i} = strrep(textcells{i},'?','');

    end   
end