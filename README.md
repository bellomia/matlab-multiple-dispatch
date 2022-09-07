# Organized multiple dispatch in Matlab
![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-D95319) 

Matlab has always shined for its great dynamic capabilities, so that _runtime polymorphism_ is basically a core feature of the language. Nevertheless the lack of type annotations in function declarations or any other trace of an explicit type system makes quite tedious to build robust _library_ code (for which standard [duck typing] would probably generate a high degree of unsafety and obscure error messages), since any check on input values has to be carried by disseminating the code with explicit assertions, via a bunch of intrinsics like `isnumeric`, `ischar`, `isreal`, etc. Here we provide an _experimental_ API to allow a more systematic way of dealing with runtime polymorphism, by mimicking [Julia's approach to multiple dispatch](https://youtu.be/kc9HwsxE1OY), or perhaps more crucially in the matlab worldview, by restricting the unlimited dynamism of the language to a more strict type hierarchy in function calls: you write many small atomic function-methods, meant to accept a few or even a single combination of types and let the dispatcher choose which implementation to call when the generic function-name is invoked. Arguably this leads to better compartmentalized development and subsequent easier maintenance, with respect to the usual big-and-generic-function-that-handles-it-all approach.

Currently we support:
- Dispatch on the number of arguments (both in and out!)
- Dispatch on the type of arguments (both intrinsic and custom[^1]) 
   
Planned:
- Dispatch on keyword arguments (via [`inputParser`](https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html)). It might take a while, for now just avoid varargins in the specialized implementations.

## Example of Usage

Write a function like the following example as your generic interface. Use `dispatch(varargin, methodTable)` in its body to define the dispatch to various specialized methods (which should be visible to the generic caller). The methodTable cell container would define the input type annotations for the multiple dispatch.

```matlab
function varargout = foo(varargin)

    methodTable = {@foo1, ["any"];  % dispatch based on number of inputs
    @foo2, ["logical","logical"];   % dispatch based on type
    @foo3, ["numeric", "logical"];
    @foo3, ["logical", "numeric"];  % repeated method for different type
    @foo4, ["Person"];              % dispatch on class
    @foo5, ["any", "logical"]};             

    [varargout{1:nargout}] = dispatch(varargin, methodTable);

end
```

The specialized methods could look like:

```matlab
function out = foo1(a)
    out = a;
end

function out = foo2(a, b)
   out = logical(a && b);
end

function out = foo3(a, b)
    out = a * b;
end

function [out1,out2] = foo4(p)
    out1 = p.name;
    out2 = p.age;
end

function [out1,out2] = foo5(a,b)
    out1 = a;
    out2 = b;
end
```

Usage in scripts, functions or command line would then be:
```matlab
% dispatch based on number of inputs
>> foo(2)
ans =
     2
```
```matlab
% dispatch based on type
>> foo(true, false)
ans =
  logical
   0
```
```matlab
% dispatch based on type
>> foo(2, true)
ans =
  2
```
```matlab
% dispatch on number of output args
>> p = Person("Amin",25);
>> foo(p) % dispatches on foo1
ans = 
  Person with properties:
    name: "Amin"
     age: 25

>> [a,b] = foo(p) % dispatches on foo4
a = 
    "Amin"
b =
    25
```
```matlab
% dispatch on any type
>> foo({2},true)
ans =
  logical
   1
```
```matlab
% error handling
>> foo({2},p)
error: no method found
```

[^1]: Please note that you [can't define custom types as matlab structs](https://www.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html), since they have no name and all share `struct` as their type. You can instead implement your custom types with the [`classdef` keyword](https://www.mathworks.com/help/matlab/ref/classdef.html) and have it work fine with the matlab-multiple-dispatch API.

## License and Copyright

The code is based on [original work](https://github.com/aminya/Dispatch.m) by A. Yahyaabadi, as such it inherits the [Apache v2 license](./LICENSE). Some fix and new functionality has been added by G. Bellomia and more changes are planned in the near future, especially regarding testing and profiling.
<!-- cite as: <bibtex?zenodo?> -->




