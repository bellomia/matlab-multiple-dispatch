function out = nargcheck(var, typearray)
% find if the method is correct based on number of passed arguments.
% calls isnargin (TODO: probably better to inline)

    narg = length(typearray);
    out = isnargin(var,narg);

end

function out = isnargin(var, num)
% is number of var equal to num
out = length(var) == num;
end