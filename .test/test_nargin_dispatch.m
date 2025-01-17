dispatch_on_nargin()

function dispatch_on_nargin

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    eval("import multimethod.interface") % stupid matlab pre-analyzes these
    eval("import multimethod.addmethod") % statements and gives error...

    f = multimethod.interface(@(x)sin(x),"float");
    f = addmethod(f,@(c)sin(str2double(c)),"char");
    f = addmethod(f,@(s)sin(str2double(s)),"string");
    f = addmethod(f,@(x,y)(sin(x)^2+cos(x)^2),["float","float"]);
    f = addmethod(f,@(x,y,z)euclidean_norm(x,y,z),["float","float","float"]);

    multimethod.showtable(f)

    fprintf("sin(pi) = %f\n",f(pi))
    fprintf("sin('0') = %f\n",f('0'))
    fprintf('sin("0") = %f\n\n',f("0"))

    fprintf("sin^2+cos^2 = %f\n\n",f(rand,rand))

    fprintf("sqrt(xx+yy+zz) = %f\n\n",f(rand,rand,rand))

    

end

function d = euclidean_norm(x,y,z)
    d = sqrt(x*x + y*y + z*z);
end