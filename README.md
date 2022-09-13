# Ergonomic Multiple Dispatch in Matlab

[![R2020a](https://img.shields.io/github/workflow/status/bellomia/matlab-multiple-dispatch/R2020a?label=R2020a&style=flat-square&logo=github)](https://github.com/bellomia/matlab-multiple-dispatch/actions/workflows/R2020a.yaml)
[![R2020b](https://img.shields.io/github/workflow/status/bellomia/matlab-multiple-dispatch/R2020b?label=R2020b&style=flat-square&logo=github)](https://github.com/bellomia/matlab-multiple-dispatch/actions/workflows/R2021a.yaml)
[![R2021a](https://img.shields.io/github/workflow/status/bellomia/matlab-multiple-dispatch/R2021a?label=R2021a&style=flat-square&logo=github)](https://github.com/bellomia/matlab-multiple-dispatch/actions/workflows/R2021a.yaml)
[![R2021b](https://img.shields.io/github/workflow/status/bellomia/matlab-multiple-dispatch/R2021b?label=R2021b&style=flat-square&logo=github)](https://github.com/bellomia/matlab-multiple-dispatch/actions/workflows/R2021b.yaml)
[![R2022a](https://img.shields.io/github/workflow/status/bellomia/matlab-multiple-dispatch/R2022a?label=R2022a&style=flat-square&logo=github)](https://github.com/bellomia/matlab-multiple-dispatch/actions/workflows/R2022a.yaml)
[![Codecov](https://img.shields.io/codecov/c/github/bellomia/matlab-multiple-dispatch?label=coverage&logo=codecov&style=flat-square)](https://codecov.io/gh/bellomia/matlab-multiple-dispatch)
![Lifecycle:Experimental](https://img.shields.io/static/v1?label=lifecycle&message=experimental&logo=git&color=gold&style=flat-square)

Matlab has always shined for its great dynamic capabilities, so that _runtime polymorphism_ is basically a core feature of the language. Nevertheless the lack of type annotations in function declarations or any other trace of an explicit type system makes quite tedious to build robust _library_ code (for which standard [duck typing] would probably generate a high degree of unsafety and obscure error messages), since any check on input values has to be carried by disseminating the code with explicit assertions, via a bunch of intrinsics like `isnumeric`, `ischar`, `isreal`, etc. Here we provide an _experimental_ API to allow a more systematic way of dealing with runtime polymorphism, by mimicking [Julia's approach to multiple dispatch](https://youtu.be/kc9HwsxE1OY), or perhaps more crucially in the matlab worldview, by restricting the unlimited dynamism of the language to a more strict type hierarchy in function calls: you write many small atomic function-methods, meant to accept a few or even a single combination of types and let the dispatcher choose which implementation to call when the generic function-name is invoked. Arguably this leads to better compartmentalized development and subsequent easier maintenance, with respect to the usual big-and-generic-function-that-handles-it-all approach.

Currently we support:
- Dispatch on the number of arguments (both in and out![^1])
- Dispatch on the type of arguments (both intrinsic and custom[^2]) 
   
Planned:
- Dispatch on keyword arguments (via [`inputParser`](https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html)). It might take a while, for now just avoid varargins in the specialized implementations.


[^1]: This needs clarifications, I intend to write a careful note, for now 🚧 Work ⚠️ in 🪜 Progress 🚧

[^2]: Please note that you [can't define custom types as matlab structs](https://www.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html), since they have no name and all share `struct` as their type. You can instead implement your custom types with the [`classdef` keyword](https://www.mathworks.com/help/matlab/ref/classdef.html) and have it work fine with the matlab-multiple-dispatch API.

## Usage

### Classic double dispatch on input types

Let's start with the basic, textbook example of double dispatch. We have two different derived types, puppies and kittens, which can meet each other, and _both_ types determine what happens on the encounter. Place somewhere in the path these class definitions:

```matlab
% pet.m
classdef (Abstract = true) pet
    properties
        name = string
    end
end

% puppy.m
classdef puppy < pet
    methods
        % constructor
        function obj = puppy(name)
            obj.name = string(name);
        end
    end
end

% kitty.m
classdef kitty < pet 
    methods
        % constructor
        function obj = kitty(name)
            obj.name = string(name);
        end
    end
end
```
And define somewhere your specialized implementations for what a pet would do to the other when meeting:

```matlab
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
```
Since you don't want to track yourself which type of animal you are pairing, so to know which of these functions to call, the multimethod package lets you build an _interface_ for them, as:

```matlab
import multimethod.interface
action = interface(@dog_meet_dog,["puppy","puppy"],...
                   @dog_meet_cat,["puppy","kitty"],...
                   @cat_meet_dog,["kitty","puppy"],...
                   @cat_meet_cat,["kitty","kitty"]);
```

As you can see, the `multimethod.interface` constructor takes an alternate list of arguments, the odd ones are the _handles_ for the specialized methods you are tying together, the even ones give the desired input-type signatures, in the form of _string arrays_ (no char vectors allowed, so remember to use `"` and not `'`).

You can check anytime such method table by invoking the provided `multimethod.showtable` function. Unfortunately other traditional inspection methods (such as opening the interface object in the builtin workspace explorer) may fail, for well-known technical reasons.[^3]

[^3]: To allow calling the interface as if it were a regular function (i.e. to making it a functor) we override the `subsref` special function, which controls the behavior of `()`, `{}`, and `.` operators, when applied to `multimethod.interface` objects. We discriminate the three within a `switch-case` block, but that works only when you call one operator at a time. Instead doing `obj.method_table(i)` or similar stuff, invokes `subsref` with two (or more) operator-types in the same call and makes the `switch` command fail. A solution may be provided by the [new `()` API introduced in R2021b](https://it.mathworks.com/help/matlab/ref/matlab.mixin.indexing.redefinesparen-class.html), but we don't want to drop support for previous versions at the moment.

```matlab
>> multimethod.showtable(action)

        methods                types         
    _______________    ______________________

    {@dog_meet_dog}    {["puppy"    "puppy"]}
    {@dog_meet_cat}    {["puppy"    "kitty"]}
    {@cat_meet_dog}    {["kitty"    "puppy"]}
    {@cat_meet_cat}    {["kitty"    "kitty"]}
```

So now let's build four different pets and make them meet in pairs:

```matlab
fido = puppy("Fido"); 
rex = puppy("Rex"); 
whisky = kitty("Whiskers");
lucy = kitty("Lucifer");

function encounter(a,b)
    act = action(a,b); % <-- Called as a regular function!
    fprintf("\n • %s meets %s and %s\n",a.name,b.name,act)
end

encounter(fido,rex)
encounter(fido,whisky)
encounter(whisky,lucy)
encounter(lucy,rex)
```
So you see the magic:

- We feed action with two pets as if it was a regular function
- It internally inspects the bundled methods, and calls the one with matching type-signature
- It can be wrapped inside other functions, as far as it is contained in a parent scope (here the `encounter` function is contained in the main scope, where the action interface object has been defined), or is it passed as a dummy argument.

This is possible since our multimethod interfaces are [_function objects (functors)_ in the C++ sense](https://en.wikipedia.org/wiki/Function_object): as such they can both store data as regular objects but also be called as regular functions.    
The only case in which an interface _could_ not behave as a full-fledged function is for handle generation. 

### Getting function handles for interfaces

Internally the `action(varargin)` syntax is an alias for the extended `multimethod.dispatch(action,varargin)` call. You can always use the verbose version to build function handles pointing to the multimethod interface but with the succinct functor syntax you have to assure you actually invoke the `()` operator.

```matlab
>> h = @(a,b)multimethod.dispatch(action,a,b);
%% Would work
>> should_sniff = h(fido,rex)

should_sniff = 

    "sniffs"

>> h = @(a,b)action(a,b)
%% Would work
>> should_hiss = h(lucy,rex)

should_hiss = 

    "hisses"

>> f = multimethod.interface(@(x)sin(x),"numeric",...
                 @(s)sin(str2double(s)),"string");
>> h = @f;  
%% Would NOT work, since 'f' does not invoke '()'
%% and then is not recognized as a function:
>> h(pi/2)
Unrecognized function or variable 'f'.
%% But if you always stick to explicit parentheses:
>> h = @(type)f(type);
%% it would work as expected!
>> one = h(pi/2)

one = % dispatch on @(x)sin(x)

     1

>> zero = h("0")

zero = % dispatch on @(s)sin(str2double(s))

     0
```

Thus the take-home message is _always use parentheses, even when you are doing trivial single-argument polymorphism_.

### Add methods and fallbacks to an existing interface

Suppose some library provides the following multimethod object:

```matlab
>> multimethod.showtable(exactplus)

             methods                      types          
    _________________________    ________________________

    {                  @plus}    {["float"    "float"  ]}
    {@(x,y)plus(double(x),y)}    {["integer"    "float"]}
    {@(x,y)plus(x,double(y))}    {["float"    "integer"]}

%% Such that

>> 3 + 4.5 == exactplus(3,4.5)

ans =

  logical

   1

%% But

>> int8(3) + 4.5 == exactplus(int8(3),4.5)

ans =

  logical

   0

%% Since

>> int8(3) + 4.5

ans =

  int8

   8

>> exactplus(int8(3),4.5)

ans =

    7.5000
```

Namely, `exactplus` does not follow the standard convention of converting all addends to the least precision (so potentially truncating the result) but instead converts integers to double floats, before invoking the built-in plus.

First of all, you may have noticed that the implementation is actually debatable, since it does not change the standard behavior when mixing single and double precision floats (it just dispatches to built-in `plus`, for any float):

```matlab
>> exactplus(single(3),4.5)

ans =

  single % <-- !!!

    7.5000
```

So we might want to add two more entries, to override the single-double and double-single signatures. This is done by invoking the `addmethod` function:

```matlab
>> import multimethod.addmethod
>> exactplus = addmethod(exactplus,...
               @(x,y)plus(double(x),y),["single","double"]);
>> exactplus = addmethod(exactplus,...
               @(x,y)plus(x,double(y)),["double","single"]);
```
Easy peasy. The `addmethod` command will _pre_-pend the new methods to the table, so that they acquire dispatch priority over the pre-existing ones (note that a "single" and a "double" variables are also recognized as "float", being it a built-in superclass for them):

```matlab
>> multimethod.showtable(exactplus)
 
             methods                      types          
    _________________________    ________________________

    {@(x,y)plus(x,double(y))}    {["double"    "single"]}
    {@(x,y)plus(double(x),y)}    {["single"    "double"]}
    {                  @plus}    {["float"    "float"  ]}
    {@(x,y)plus(double(x),y)}    {["integer"    "float"]}
    {@(x,y)plus(x,double(y))}    {["float"    "integer"]}
```

In general the table is always navigated from the top to the bottom, while parsing the input signatures, and the first compatible entry would define the actual dispatch and exit. So that you can tune the dispatching priority by just defining the order in which the methods are listed.

You might be asking now... how to append a fallback method, which has to be given lower priority than the existing, more specialized, ones? For that we provide the `addfallback` command, with same syntax as `addmethod`:

```matlab
>> shadowplus = addmethod(exactplus,@plus,["any","any"]);
>> multimethod.showtable(shadowplus)
 
             methods                      types          
    _________________________    ________________________

    {                  @plus}    {["any"    "any"      ]}
    {@(x,y)plus(x,double(y))}    {["double"    "single"]}
    {@(x,y)plus(double(x),y)}    {["single"    "double"]}
    {                  @plus}    {["float"    "float"  ]}
    {@(x,y)plus(double(x),y)}    {["integer"    "float"]}
    {@(x,y)plus(x,double(y))}    {["float"    "integer"]}

>> shadowplus(4.5,int8(3))

ans =

  int8

   8  

%% NO! We are shadowing the specialized methods for integers here!
%% > Let's use instead multimethod.addfalback:
>> import multimethod.addfallback
>> exactplus = addfallback(exactplus,@plus,["any","any"]);
>> multimethod.showtable(exactplus)
 
             methods                      types          
    _________________________    ________________________

    {@(x,y)plus(x,double(y))}    {["double"    "single"]}
    {@(x,y)plus(double(x),y)}    {["single"    "double"]}
    {                  @plus}    {["float"    "float"  ]}
    {@(x,y)plus(double(x),y)}    {["integer"    "float"]}
    {@(x,y)plus(x,double(y))}    {["float"    "integer"]}
    {                  @plus}    {["any"    "any"      ]}

>> exactplus(4.5,int8(3))

ans =

    7.5000 % correct specialized dispatch for float-int

>> exactplus(int8(3),int8(4))

ans =

  int8

   7  % correct fallback dispatch for all-integers

>> exactplus("fall","back")

ans = 

    "fallback" % of course fallback works also for strings
>>             % > "any" matches with all intrinsic and custom types!    
```

Note that for the most flexibility we have overloaded the `+` operator for multimethod interface objects, so that you could generate many interfaces and concatenate them just as a (noncommutative) addition, like in:

```matlab
>> f = interface(@(i)sin(double(i)),"integer")

f = 

  interface with properties:

    method_table: {@(i)sin(double(i))  ["integer"]}

>> f(int16(3))

ans =

    0.1411

%% So f() it's just a single-method interface for a 
%% sine acting on integer angles (ndr. sin does not 
%% take integers in matlab). Of course we'd want to 
%% call just @sin for a float, for optimal speed.
%% Suppose we don't know about the "float" abstract
%% class, but only about "numeric", which includes
%% integers. Adding {@sin, ["numeric"]} to the top 
%% will of course overshadow the original method,
%% so breaking the functionality for integers.
%% Adding instead two string-friendly entries for
%% both the "string" and the "char" types poses no
%% problems whatsoever, so that might well come on 
%% top of everything. All this can be obtained as:

>> f = interface(@(s)sin(str2double(s)),"string") + ...
       interface(@(c)sin(str2double(c)), "char" ) + ...
       f + interface(@sin,"numeric");

>> multimethod.showtable(f)
 
            methods                 types    
    ________________________    _____________

    {@(s)sin(str2double(s))}    {["string" ]}
    {@(c)sin(str2double(c))}    {["char"   ]}
    {    @(i)sin(double(i))}    {["integer"]}
    {                  @sin}    {["numeric"]}
    
>> f(3)

ans =

    0.1411

>> f('3')

ans =

    0.1411
 
>> f("3")

ans =

    0.1411

>> f(uint32(3))

ans =

    0.1411
```

### Dispatch on number of input arguments

So far we have showed only examples in which all signatures conform to the same number of input arguments. This is not mandatory, of course, rather you could add methods with signatures that are different only for the number of required arguments, instead of types.

Such a script:

```matlab
f = multimethod.interface(@(x)sin(x),"float");

import multimethod.addmethod

f = addmethod(f,@(x,y)(sin(x)^2+cos(x)^2),["float","float"]);
f = addmethod(f,@(x,y,z)euclidean_norm(x,y,z),["float","float","float"]);

function d = euclidean_norm(x,y,z)
         d = sqrt(x*x + y*y + z*z);
end
```
would allow to
```matlab
>> f(double(pi))

ans =

   1.2246e-16

>> f(single(pi))

ans =

  single

  -8.7423e-08

>> f(3,4,single(12))

ans =

  single

    13
```

Of course you can also mix dispatch on type and dispatch on _nargin_:

```matlab
>> f = addmethod(f,@(c)sin(str2double(c)),"char");
>> f = addmethod(f,@(s)sin(str2double(s)),"string");
>> f('0')

ans =

     0

>> f("0")

ans =

     0

>> f(0,single(0),0)

ans =

  single

     0

>> f(0,0)

ans =

     1   % = cos(0) :)
```

### Dispatch on number of _output_ arguments

This is subtle, hence requires some careful writing. Coming soon...

🚧 Work ⚠️ in 🪜 Progress 🚧


## License and Copyright
The code is based on [original work](https://github.com/aminya/Dispatch.m) by A. Yahyaabadi, as such it inherits the [Apache v2 license](./LICENSE). Deeply refactored to enable new functionality and provide as most an ergonomic user experience as possible. The new API is accompanied by a thorough test-suite, that can be ran entering the `.test/` directory and invoking the `runtests` matlab command.
```
Copyright 2020 Amin Yahyaabadi [original dispatch.m function]    
Copyright 2022 Gabriele Bellomia [full multimethod namespace] 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

<!-- cite as: <bibtex?zenodo?> -->




