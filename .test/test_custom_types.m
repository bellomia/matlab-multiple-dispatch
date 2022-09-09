
class_based_dispatch()

function class_based_dispatch

    % Custom defined person type (see person.m)
    gb = person('Gabriele Bellomia',28) %#ok to print
    % Built-in data structure to represent a person
    cm = struct('name','Cleve Barry Moler','age',83) %#ok to print

    here = pwd;
    cd .. % we need to see the +multimethod namespace

    f = multimethod.interface();
    f = f.add_method(@who_am_i__struct,"struct");
    f = f.add_method(@who_am_i__person,"person");
    disp(f); who_am_I = f.activate %#ok to print

    who_am_I(gb);
    who_am_I(cm);

    cd(here)

end

function who_am_i__person(p)

    fprintf('\nHi! I am %s, and have been born %d year ago\n',p.name,p.age)
    disp("Pssst, I'm a person")

end

function who_am_i__struct(p)

    fprintf('\nHi! I am %s, and have been born %d year ago\n',p.name,p.age)
    disp("Pssst, I'm a just a struct, like any true old C programmer")

end