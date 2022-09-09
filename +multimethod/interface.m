% Organized multiple dispatch for Matlab :: multimethod interface class
% Apache V2 License
% Copyright (c) 2022 Gabriele Bellomia
classdef (Sealed = true) interface

  properties (SetAccess = protected)

    method_table = cell(0)

  end

  methods

    %% constructor
    function functor = interface(varargin) 
    % >> multimethod_interface = interface(@fun_1,sign_1,@fun_2,sign_2...)
    % @fun_i are function handles or lambda functions
    % sign_i are input type signatures :: string arrays (no char arrays!)
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
            functor.method_table{i} = varargin{i};
        end
    end

    %% functor user interface
    function varargout = subsref(functor,indexing)
    % >> varargout = multimethod_interface(varargin)
    % This is a special operator overload that makes the interface behave 
    % as a regular generic function, that dispatches on specialized methods
        switch(indexing.type)
            case '()'
                [varargout{1:nargout}] = multimethod.dispatch(functor,indexing.subs{:});
            case '{}'
                error('{} indexing not supported for multimethod functorects')
            otherwise
                [varargout{1:nargout}] = builtin('subsref', functor, indexing);
        end
    end

    %% equality overloader
    function bool = eq(functor,gunctor)
    % >> f_interface == g_interface
    % This is a special operator overload that makes possibile to evaluate
    % the equality of two multimethod functors (duplicate methods unaware)
        ftable = functor.method_table;
        gtable = gunctor.method_table;
        %ftable = unique(ftable); DOES NOT WORK
        %gtable = unique(gtable); WE SHOULD FIX
        bool = isequal(ftable,gtable);
    end

  end

end