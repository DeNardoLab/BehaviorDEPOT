function slash = addSlash()

if ispc()
    slash = '\';

elseif isunix()
    slash = '/';
    
end