% Organized multiple dispatch for Matlab :: multimethod.dispatch
% Apache V2 License
% Copyright (c) 2020 Amin Yahyaabadi [original dispatch.m function]
% Copyright (c) 2022 Gabriele Bellomia [multimethod interface class]
%
% USAGE:
% >> varargout = dispatch(multimethod_interface,varargin)
%    --> would parse the method table and dispatch on the first match
function varargout = dispatch(functor,varargin)
    if nargout < 1
        disp 'Dispatching multimethod interface to specialized implementation'
    end
    table_list = functor.method_table;
    method_list = table_list(1:2:end);
    type_list = table_list(2:2:end);
    var = varargin;
    methodNum = length(method_list);
    for i=1:methodNum
        if nargcheck(var,type_list{i})
            % only check types if nargin matches
            if ismethod(var, type_list{i})
                % call the candidate matching method
                try % the only way I know to check for nargout match
                    [varargout{1:nargout}] = method_list{i}(var{:});
                    return
                catch ME
                    warning(['failed dispatch to @%s due to «',ME.message,...
                             '». We''ll continue searching for a match ' ,...
                             'but you should avoid this to assure best ' ,...
                             'performance.\n'], char(method_list{i}))
                    continue % there might be another method matching
                end
            end
        end
    end
    fprintf(2,"Error: no matching specialized method found in\n")
    multimethod.showtable(functor)
    [varargout{1:nargout}] = [];
    return
end