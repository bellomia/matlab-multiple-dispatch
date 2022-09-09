test_no_argouts()

function test_no_argouts

    here = pwd;
    cd .. % we need to see the +multimethod namespace

    multimethod.interface
    ans.add_method(@sin,"any")
    ans.activate
    ans(pi/2)

    cd(here)

end