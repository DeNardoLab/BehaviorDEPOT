function vector = makeVector(tbl, vector_length)
    if istable(tbl)
        tbl = table2array(tbl);
    end
    vector = zeros(1, vector_length);
    for i = 1:size(tbl, 1)
        vector(tbl(i, 1):tbl(i, 2)) = 1;
    end
end