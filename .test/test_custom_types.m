
class_based_dispatch()

function class_based_dispatch

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    % Custom defined person type (see person.m)
    gb = person('Gabriele Bellomia',28) %#ok to print
    % Built-in data structure to represent a person
    cm = struct('name','Cleve Barry Moler','age',83) %#ok to print

    who_am_I = multimethod.interface();
    who_am_I = multimethod.addmethod(who_am_I,@who_am_i__struct,"struct");
    who_am_I = multimethod.addmethod(who_am_I,@who_am_i__person,"person");
    multimethod.showtable(who_am_I)

    who_am_I(gb);
    who_am_I(cm);

    rmpath(root)

end

function who_am_i__person(p)

    fprintf('\nHi! I am %s, and have been born %d year ago\n',p.name,p.age)
    disp("Pssst, I'm a person")

end

function who_am_i__struct(p)

    fprintf('\nHi! I am %s, and have been born %d year ago\n',p.name,p.age)
    disp("Pssst, I'm a just a struct, like any true old C programmer")

end