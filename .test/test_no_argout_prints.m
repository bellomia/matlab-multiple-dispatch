test_no_argouts()

function test_no_argouts

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    multimethod.interface
    multimethod.addmethod(ans,@sin,"float")
    multimethod.addfallback(ans,@cos,"any")
    ans(pi/2)

    

end
