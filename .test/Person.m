classdef person 
    properties
        name
        age
    end   
    methods
        % constructor
        function obj = person(name,age)
            obj.name = name;
            obj.age = age;
        end
    end
end

