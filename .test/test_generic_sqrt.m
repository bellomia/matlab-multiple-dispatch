
test_sqrt_dispatch();

function test_sqrt_dispatch

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    eval("import multimethod.interface") % stupid matlab pre-analyzes these
    eval("import multimethod.addmethod") % statements and gives error...

    disp("Let's start with standard matlab sqrt for generic numbers")
    multisqrt = interface(@(z)sqrt(z),"float");
    multimethod.showtable(multisqrt)

    disp("Let's add a method for character arrays")
    multisqrt = addmethod(multisqrt,@(s)sqrt(str2double(s)),"char");
    multimethod.showtable(multisqrt)

    disp("Let's try to dispatch")
    fprintf("multisqrt(4) = %d\n",multisqrt(4));
    fprintf("multisqrt('4') = %d\n",multisqrt('4'));
    fprintf('multisqrt("4") = OPS!\n')
    multisqrt("4")

    disp('We have failed cause "4" is a string, not a char!')
    disp("Let's duplicate the char method to strings then :)")
    multisqrt = addmethod(multisqrt,@(s)sqrt(str2double(s)),"string");
    multimethod.showtable(multisqrt)

    disp("Retest:")
    fprintf('multisqrt("4") = %d\n\n',multisqrt("4"));

    

end
