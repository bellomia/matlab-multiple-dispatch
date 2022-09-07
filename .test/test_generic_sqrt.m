
test_sqrt_dispatch();

function test_sqrt_dispatch

    here = pwd;
    cd .. % we need to see the +multimethod namespace

    disp("Let's start with standard matlab sqrt for generic numbers")
    multisqrt = multimethod.interface(@(z)sqrt(z),"numeric") %#ok to print

    disp("Let's add a method for character arrays")
    multisqrt = multisqrt.add_method(@(s)sqrt(str2double(s)),"char") %#ok to print

    disp("Let's activate the interface")
    generic_sqrt = multisqrt.activate %#ok to print

    disp("Let's try to dispatch")
    fprintf("generic_sqrt(4) = %d\n",generic_sqrt(4));
    fprintf("generic_sqrt('4') = %d\n",generic_sqrt('4'));
    fprintf('generic_sqrt("4") = OPS!\n')
    generic_sqrt("4")

    disp('We have failed cause "4" is a string, not a char!')
    disp("Let's duplicate the char method to strings then :)")
    multisqrt = multisqrt.add_method(@(s)sqrt(str2double(s)),"string") %#ok to print

    disp("Reload & Retest:")
    generic_sqrt = multisqrt.activate %#ok to print
    fprintf('generic_sqrt("4") = %d\n\n',generic_sqrt("4"));

    cd(here)

end
