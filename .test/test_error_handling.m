test_runtime_errors()

function test_runtime_errors

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    %% interface class
    disp("INTERFACE CONSTRUCTOR")
    multimethod.interface(@min) % nargin must be even
    multimethod.interface(@min,'any') % signature must be string (no char!)
    multimethod.interface("min","any") % method must be function handle
    multimethod.interface(@min,"any") % finally emitting an interface
    ans{1}; %#ok: try to index with braces instead of parentheses

    %% dispatch function
    disp("DISPATCH FUNCTION")
    f = multimethod.interface(@cos,"numeric",@sin,"numeric");
    multimethod.showtable(f)
    disp("Of course we cannot dispatch on this...let's try!")
    disp(">> y = multimethod.dispatch(f,pi/2)")
    y = multimethod.dispatch(f,pi/2) %#ok to print
    disp("As you see, we have selected just the first encountered method.")
    disp("Let's try instead with a char... no method would be found!")
    disp(">> y = multimethod.dispatch(f,'pi/2')")
    y = multimethod.dispatch(f,'pi/2') %#ok to print
    disp("Let's add a 2-argout method dispatching again on {'numeric'}")
    f = multimethod.addmethod(f,@sin_and_cos,"numeric");
    multimethod.showtable(f)
    disp(">> cosine = f(pi/2)")
    cosine = f(pi/2) %#ok to print
    disp(">> [sine,cosine] = f(pi/2)")
    [sine,cosine] = f(pi/2) %#ok to print
    disp("Oh no! We failed to dispatch on number of out arguments, that's")
    disp("because sin_and_cos has the freedom to throw just the first out")
    disp("and it is placed on the head of the method table. If we add it ")
    disp("again we obtain the desired 1-arg dispatch, since the addmethod")
    disp("function does /prepend/ to the table.")
    disp(" ")
    disp('>> f = addmethod(f,@cos,"numeric");')
    disp(">> cosine = f(pi/2)")
    f = multimethod.addmethod(f,@cos,"numeric");
    cosine = f(pi/2) %#ok to print
    disp(">> [sine,cosine] = f(pi/2)")
    [sine,cosine] = f(pi/2) %#ok to print
    disp("You should probably avoid this though, for better performance.")
    disp(" ")


    %% addmethod
    disp("ADDMETHOD FUNCTION")
    disp(' ')
    disp("Finally, remember that you cannot give type signatures as chars:")
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