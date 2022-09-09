% Organized multiple dispatch for Matlab :: multimethod.show_table
% Apache V2 License
% Copyright (c) 2022 Gabriele Bellomia
%
% USAGE:
% >> showtable(multimethod_interface)
function showtable(functor)
    tab = functor.method_table;
    methods = tab(1:2:end)';
    types = tab(2:2:end)';
    tab = table(methods,types);
    disp(tab)
end