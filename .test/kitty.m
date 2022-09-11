% Warning: Function cat has the same name as a
% MATLAB builtin. We suggest you rename the
% function to avoid a potential name conflict.
% >> so let's name them kittens I guess...
classdef kitty < pet 
    methods
        % constructor
        function obj = kitty(name)
            obj.name = string(name);
        end
    end
end