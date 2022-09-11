test_dispatch_priorities()

function test_dispatch_priorities

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    exactplus = multimethod.interface(@plus,["float","float"]) %#ok print

    disp("This plus for now only works for floating-point arguments.")
    disp("Mixing floats and integers would need a special treatment,")
    disp("for that plus converts everything to integer, dropping the")
    disp("mantissa by rounding. An exact plus would convert to float")
    disp("instead, so to keep all the precision. So let's extend:")
    disp(" ")
    disp(">> exactplus = exactplus + multimethod.interface(...)")
    exactplus = exactplus + multimethod.interface(...
                @(x,y)plus(double(x),y),["integer","float"],...
                @(x,y)plus(x,double(y)),["float","integer"]);

    multimethod.showtable(exactplus)

    disp("Let's try something...")
    disp(">> 3 + 4.5")
    3 + 4.5 %#ok print
    disp(">> int8(3) + 4.5")
    int8(3) + 4.5 %#ok print
    disp(">> exactplus(int8(3),4.5)")
    exactplus(int8(3),4.5) 
    disp(">> exactplus(4.5,int8(3))")
    exactplus(4.5,int8(3)) 
    disp(">> exactplus(int8(3),int8(4))")
    exactplus(int8(3),int8(4)) 

    disp("Oops, we have no method for pure integer operations, which we")
    disp("/do not/ want to convert to float! But instead of adding just")
    disp("one method for the integer-integer signature, let's extend to")
    disp("everything else, so that exactplus is fully generic.")
    disp(" ")
    disp("But careful, if we call addmethod we prepend to the table and")
    disp("give priority to the generic signature, causing a shadowing  ")
    disp("of all specialized methods. See:")
    disp(" ")
    disp('shadowplus = addmethod(exactplus,@plus,["any","any"])')
    shadowplus = multimethod.addmethod(exactplus,@plus,["any","any"]);
    multimethod.showtable(shadowplus)
    disp(">> shadowplus(4.5,int8(3))")
    shadowplus(4.5,int8(3)) 
    
    disp("What you should instead do in such a case is to add a fallback")
    disp("which would instead append to the table and achieve the right ")
    disp("fallback behavior :)")
    disp('exactplus = addfallback(exactplus,@plus,["any","any"])')
    exactplus = multimethod.addfallback(exactplus,@plus,["any","any"]);
    multimethod.showtable(exactplus)
    disp(">> exactplus(4.5,int8(3))")
    exactplus(4.5,int8(3)) 
    disp(">> exactplus(int8(3),int8(4))")
    exactplus(int8(3),int8(4)) 
    disp('>> exactplus("fall","back")')
    exactplus("fall","back")

    rmpath(root)

end