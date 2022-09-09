function out = ismethod(var, types)
% find if the method is correct based on type of arguments.
% calls eisa
    out = eisa(var, types);
end