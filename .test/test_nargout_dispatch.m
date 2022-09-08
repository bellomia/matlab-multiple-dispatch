dispatch_on_nargout()

function dispatch_on_nargout

    here = pwd;
    cd .. % we need to see the +multimethod namespace

    f = multimethod.interface;
    f = f.add_method(@sin_and_cos,"numeric");
    f = f.add_method(@(x)tan(x),"numeric");
    f = f.activate;

    disp(f)

    x = 2*pi*rand;

    disp("Compute tan(x) as t = f(x)")
    t = f(x) %#ok to print

    disp("Compute tan(x) as [s,c] = f(x); t = s/c")
    [s,c] = f(x); s/c %#ok to print
    assert(norm(t-s/c)/norm(t)<1e-8,"Error: the two tangents do not match")
    t = s/c %#ok to print

    cd(here)

end

function [s,c] = sin_and_cos(x)
    s = sin(x);
    c = cos(x);
end