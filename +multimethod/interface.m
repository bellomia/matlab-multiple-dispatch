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
            fprintf(2,'Error: number of input arguments must be even\n')
            return
        end
        if not(visa(varargin(1:2:end),"function_handle"))
            fprintf(2,'Error: odd input arguments must be functions\n')
            return
        end
        if not(visa(varargin(2:2:end),"string"))
            fprintf(2,'Error: even input arguments must be strings\n')
            return
        end
        if nargout < 1
            disp 'Emitting new instance of multimethod interface\n'
        end
        for i = 1:nargin
            functor.method_table{i} = varargin{i};
        end
    end

    %% functor user interface
    function varargout = subsref(functor,indexing)
    % >> varargout = multimethod_interface(varargin)
    % This is a special operator overload that makes the interface behave 
    % as a regular generic function that dispatches on specialized methods.
    % The dispatch happens by parsing the internal method-signature table,
    % and selecting the first match (same input signature and nargout).
        switch(indexing.type)
            case '()'
                [varargout{1:nargout}] = multimethod.dispatch(functor,indexing.subs{:});
            case '{}'
                fprintf(2,'{·} indexing not supported for multimethod interfaces\n')
                [varargout{1:nargout}] = []; 
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
        bool = isequal(ftable,gtable);
    end

    %% addition overloader
    function sumntor = plus(functor,gunctor)
    % >> f_interface + g_interface
    % This is a special operator overload defining noncommutative addition 
    % of two interfaces, by concatenating their method tables.
    % Noncommutativity is crucial to define priority in dispatch, since we
    % parse the method table sequentially and exit at first match.
        ftable = functor.method_table;
        gtable = gunctor.method_table;
        stable = horzcat(ftable,gtable);
        sumntor = multimethod.interface(stable{:});
    end

  end
  
end