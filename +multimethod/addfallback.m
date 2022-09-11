% Organized multiple dispatch for Matlab :: multimethod.addfallback
% Apache V2 License
% Copyright (c) 2022 Gabriele Bellomia
%
% USAGE:
% >> multimethod_obj = addfallback(multimethod_obj,@fun,type_signature)
%    --> will /post/pend the new method to the existing table, so that
%        it could provide a nonspecialized fallback to existing methods. 
function functor = addfallback(functor,handle,types)
    valid_types_format = visa({types},"string");
    if not(valid_types_format)
        fprintf(2,'Error: type_signature must be a string array\n')
        return
    end
    if nargout < 1
        disp 'Appending new implementation to multimethod interface'
    end
    old_table = functor.method_table;
    new_table = [old_table,{handle},{types}];
    functor = multimethod.interface(new_table{:});
end