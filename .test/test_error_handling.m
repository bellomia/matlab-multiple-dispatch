test_runtime_errors()

function test_runtime_errors

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    %% interface class
    multimethod.interface(@min) % nargin must be even
    multimethod.interface(@min,'any') % signature must be string (no char!)
    multimethod.interface("min","any") % method must be function handle
    multimethod.interface(@min,"any") % finally emitting an interface
    ans{1}; %#ok: try to index with braces instead of parentheses

    %% dispatch function
    f = multimethod.interface(@sin,"numeric",@cos,"numeric");
    multimethod.showtable(f)
    disp("Of course we cannot dispatch on this...let's try!")
    disp(">> y = multimethod.dispatch(f,pi/2)")
    y = multimethod.dispatch(f,pi/2) %#ok to print
    disp("Let's try instead with a char... no method would be found!")
    disp(">> y = multimethod.dispatch(f,'pi/2')")
    y = multimethod.dispatch(f,'pi/2') %#ok to print
    disp("Let's add a 2-argout method dispatching again on {'numeric'}")
    f = multimethod.addmethod(f,@sin_and_cos,"numeric");
    multimethod.showtable(f)
    disp(">> [sine,cosine] = f(pi/2)")
    [sine,cosine] = f(pi/2) %#ok to print
    disp("Oh yeah! We managed to select sin_and_cos via nargout dispatch")

    %% addmethod
    disp(' ')
    disp("Remember that you cannot give type signatures as chars:")
    disp(">> f = addmethod(f,@sqrt,'float')")
    f = multimethod.addmethod(f,@sqrt,'float');
    disp(' ')
    multimethod.showtable(f)
    disp("So we need to provide them always as string (arrays):")
    disp('>> f = addmethod(f,@sqrt,"float")')
    f = multimethod.addmethod(f,@sqrt,"float"); multimethod.showtable(f)


    rmpath(root);
end

function [s,c] = sin_and_cos(x)
    s = sin(x);
    c = cos(x);
end