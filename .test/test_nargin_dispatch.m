dispatch_on_nargin()

function dispatch_on_nargin

    here = pwd;
    cd .. % we need to see the +multimethod namespace

    f = multimethod.interface(@(x)sin(x),"numeric");
    f = f.add_method(@(c)sin(str2double(c)),"char");
    f = f.add_method(@(s)sin(str2double(s)),"string");
    f = f.add_method(@(x,y)(sin(x)^2+cos(x)^2),["numeric","numeric"]);
    f = f.add_method(@(x,y,z)euclidean_norm(x,y,z),["numeric","numeric","numeric"]);

    disp(f)

    fprintf("sin(pi) = %f\n",f.dispatch(pi))
    fprintf("sin('0') = %f\n",f.dispatch('0'))
    fprintf('sin("0") = %f\n\n',f.dispatch("0"))

    fprintf("sin^2+cos^2 = %f\n\n",f.dispatch(rand,rand))

    fprintf("sqrt(xx+yy+zz) = %f\n\n",f.dispatch(rand,rand,rand))


    cd(here)

end

function d = euclidean_norm(x,y,z)
    d = sqrt(x*x + y*y + z*z);
end