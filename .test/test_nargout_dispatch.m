dispatch_on_nargout()

function dispatch_on_nargout

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    f = multimethod.interface(@tan_sincos,"numeric");

    disp(f)
    disp('Unfortunately we cannot discriminate methods on nargout')
    disp('but still we can capture a variable number of  outputs,')
    disp('so nargout polymorphism is still doable inside methods.')

    disp('x = 2*pi*rand(3)');
    x = 2*pi*rand(3) %#ok to print

    disp("Compute tan(x) as t = f(x)")
    t = f(x) %#ok to print

    disp("Compute tan(x) as [s,c] = f(x); t = s./c")
    [s,c] = f(x); s./c %#ok to print
    assert(norm(t-s./c)/norm(t)<1e-8,"Error: the two tangents do not match")

    disp("Compute everything within method as [t,s,c] = f(x)")
    [t,s,c] = f(x) %#ok to print
    assert(norm(t-s./c)/norm(t)<1e-8,"Error: the two tangents do not match")

    rmpath(root);

end

function [a,b,c] = tan_sincos(x)
    switch nargout
        case 1
            a = tan(x);
        case 2
            a = sin(x);
            b = cos(x);
        case 3
            b = sin(x);
            c = cos(x);
            a = sin(x)./cos(x);
    end
end