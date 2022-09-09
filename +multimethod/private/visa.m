function out = visa(var, type)
% vectorized isa
    type = repmat(type,1,length(var));
    out = eisa(var, type);
end