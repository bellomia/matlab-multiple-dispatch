% Runtime multiple dispatch for Matlab.
% Apache V2 License
% Copyright (c) 2020 Amin Yahyaabadi [original dispatch.m function]
% Copyright (c) 2022 Gabriele Bellomia [multimethod.interface class] 
classdef interface

  properties

    method_table = cell(0)

  end

  methods

    %% constructor
    function obj = interface(varargin) 
    % >> multimethod_obj = interface(@fun1,signature1,@fun2,signature2...)
        if mod(nargin,2) == 1
            fprintf(2,'Error: number of input arguments must be even')
            return
        end
        if not(visa(varargin(1:2:end),"function_handle"))
            fprintf(2,'Error: odd input arguments must be functions')
            return
        end
        if not(visa(varargin(2:2:end),"string"))
            fprintf(2,'Error: even input arguments must be strings')
            return
        end
        if nargout < 1
            disp 'Emitting new instance of multimethod interface'
        end
        for i = 1:nargin
            obj.method_table{i} = varargin{i};
        end
    end

    %% grower
    function obj = add_method(obj,handle,types)
    % >> multimethod_obj.add_method(@fun,input_type_signature)
        valid_types_format = visa({types},"string");
        if not(valid_types_format)
            fprintf(2,'Error: type_signature must be a string array')
            return
        end
        if nargout < 1
            disp 'Appending new implementation to multimethod interface'
        end
        obj.method_table = [obj.method_table,{handle},{types}];
    end

    %% activator               ↓ not obj to have transparent messages
    function handle = activate(multimethod) 
    % >> handle = multimethod_obj.activate
        if nargout < 1
            disp 'Packing multimethod interface into a function handle'
        end
        handle = @(varargin)multimethod.dispatch(varargin{:});
    end

    %% dispatcher
    function varargout = dispatch(obj,varargin)
    % >> varargout = multimethod_obj.dispatch(varargin)
        if nargout < 1
            disp 'Dispatching multimethod interface to specialized implementations'
        end
        method_list = obj.method_table(1:2:end);
        type_list = obj.method_table(2:2:end);
        var = varargin;
        methodNum = length(method_list);
        for i=1:methodNum
            if nargcheck(var,type_list{i})
                % only check types if nargin matches
                if ismethod(var, type_list{i})
                    % call the candidate matching method
                    try % the only way I know to check for nargout match
                        [varargout{1:nargout}] = method_list{i}(var{:});
                    catch
                        continue % there might be another method matching
                    end
                    return
                end
            end
        end
        fprintf(2,"Error: no matching specialized method found in\n")
        disp(obj)
        return
    end
  end
end

%% private

function out = nargcheck(var, typearray)
% find if the method is correct based on number of passed arguments.
% calls isnargin (TODO: probably better to inline)

    narg = length(typearray);
    out = isnargin(var,narg);

end

function out = ismethod(var, types)
% find if the method is correct based on type of arguments.
% calls eisa (TODO: probably better to inline)

    out = eisa(var, types);

end

function out = isnargin(var, num)
% is number of var equal to num
out = length(var) == num;
end

function out = visa(var, type)
% vectorized isa
    type = repmat(type,1,length(var));
    out = eisa(var, type);
end

function out = eisa(var, type)
% elemental isa
%
% # Example
% % use in type dispatch:
% eisa(varargin,{"any","any"})
% eisa(varargin,{"numeric","numeric"})
% eisa(varargin,{"double","single"})
% eisa(varargin,{"numeric","cell", "struct"})

% if number of arguments doesn't match the types, it returns false

    varlen = length(var);
    typelen = length(type);

    varisa = false(typelen,1); % uses typelen and set default to false

    for i = 1:varlen
        varisa(i) = isa_(var{i},type{i});
    end

    out = all(varisa);
end

function out = isa_(var, type)
% custom isa function. It adds "any" type to Matlab

    if type == "any"
        out = true;
    else
        out = isa(var, type);
    end

end