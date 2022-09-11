class_based_dispatch()

function class_based_dispatch

    root = erase(fileparts(mfilename('fullpath')),'.test');
    addpath(root) % we need to see the +multimethod namespace

    disp("Let's start simple: two people introducing themselves")

    % Custom defined person type (see person.m)
    gb = person('Gabriele Bellomia',28) %#ok to print
    % Built-in data structure to represent a person
    cm = struct('name','Cleve Barry Moler','age',83) %#ok to print

    who_am_I = multimethod.interface();
    who_am_I = multimethod.addmethod(who_am_I,@who_am_i__struct,"struct");
    who_am_I = multimethod.addmethod(who_am_I,@who_am_i__person,"person");
    multimethod.showtable(who_am_I)

    who_am_I(gb);
    who_am_I(cm);

    disp("Ok, ok, this is single dispatch, easy done through intheritance")
    disp(" ")
    disp("So let's go further with /double/ dispatch!")
    disp(" ")

    fprintf("Here you have two puppies:\n\n")
    fido = puppy("Fido"); disp(fido.name)
    rex = puppy("Rex"); disp(rex.name)
    fprintf("\nAnd two kittens:\n\n")
    whisky = kitty("Whiskers"); disp(whisky.name)
    lucy = kitty("Lucifer"); disp(lucy.name)

    fprintf("And a this nice method table:\n")
    % Build appropriate multimethod (which would come from a library)
    action = multimethod.interface(@dog_meet_dog,["puppy","puppy"],...
                                   @dog_meet_cat,["puppy","kitty"],...
                                   @cat_meet_dog,["kitty","puppy"],...
                                   @cat_meet_cat,["kitty","kitty"]);
    % And wrap the encounter in a "client" procedure written by user
    function encounter(pet1,pet2)
        act = action(pet1,pet2);
        fprintf("\n • %s meets %s and %s\n",pet1.name,pet2.name,act)
    end
    % Display to stdout
    multimethod.showtable(action)

    fprintf("\nSo let's make they all meet in pairs!\n")
    encounter(fido,rex)
    encounter(fido,whisky)
    encounter(whisky,lucy)
    encounter(lucy,rex)
    
    fprintf("\nWe can even override inverting the parent/derived order:\n")
    action = multimethod.addmethod(action,@pet_meet_cat,["pet","kitty"]);
    action = multimethod.addmethod(action,@pet_meet_dog,["pet","puppy"]);
    multimethod.showtable(action)
    fprintf("\nREMATCH:\n")
    encounter(fido,rex)
    encounter(fido,whisky)
    encounter(whisky,lucy)
    encounter(lucy,rex)

    rmpath(root)

end

%% SPECIALIZED IMPLEMENTETIONS OF ACTION
function action = dog_meet_dog(~,~)
    action = "sniffs";
end

function action = dog_meet_cat(~,~)
    action = "chases";
end

function action = cat_meet_dog(~,~)
    action = "hisses";
end

function action = cat_meet_cat(~,~)
    action = "purrs";
end

function action = pet_meet_cat(~,~)
    action = "say hello fellow cat";
end

function action = pet_meet_dog(~,~)
    action = "say hello fellow dog";
end

%% SPECIALIZED IMPLEMENTATIONS OF WHO_AM_I
function who_am_i__person(p)

    fprintf('\nHi! I am %s, and have been born %d year ago\n',p.name,p.age)
    disp("Pssst, I'm a person")

end

function who_am_i__struct(p)

    fprintf('\nHi! I am %s, and have been born %d year ago\n',p.name,p.age)
    disp("Pssst, I'm just a struct, like any true old C programmer")

end