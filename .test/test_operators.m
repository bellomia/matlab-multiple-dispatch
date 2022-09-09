test_eq_and_plus_operators()

function test_eq_and_plus_operators

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    f = multimethod.interface(@sin,"single") %#ok to print
    g = multimethod.interface(@sin,"double") %#ok to print

    disp('>> f == g')
    f == g %#ok to print

    disp("But let's now add the single and double methods:")
    disp('>> h = f + g')
    h = f + g; multimethod.showtable(h)

    disp('Would it be equal to interface(@sin,"float")?')
    disp('>> interface(@sin,"float") == h')
    multimethod.interface(@sin,"float") == h %#ok to print

    disp("Of course not! We know nothing about type unions...")
    disp("Maybe one day we would add support for that :)")
    disp(' ')
    disp("But do we at least have commutativity??")
    disp('>> f + g')
    multimethod.showtable(f+g)
    disp('>> g + f')
    multimethod.showtable(g+f)
    disp('>> f + g == g + f')
    f + g == g + f %#ok to print
    disp("Oh no! Sorry, these are surely rough edges.   ")
    disp("For now, the method tables must be identical, ")
    disp("in contents, ordering, and without duplicates.")
    disp(' ')
    disp(' ')
    disp('Well, well, does at least work for ( f == f )?!')
    disp('>> f == f')
    f == f %#ok to print

    rmpath(root)

end