# Organized multiple dispatch in Matlab
![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-D95319) 

Matlab has always shined for its great dynamic capabilities, so that _runtime polymorphism_ is basically a core feature of the language. Nevertheless the lack of type annotations in function declarations or any other trace of an explicit type system makes quite tedious to build robust _library_ code (for which standard [duck typing] would probably generate a high degree of unsafety and obscure error messages), since any check on input values has to be carried by disseminating the code with explicit assertions, via a bunch of intrinsics like `isnumeric`, `ischar`, `isreal`, etc. Here we provide an _experimental_ API to allow a more systematic way of dealing with runtime polymorphism, by mimicking [Julia's approach to multiple dispatch](https://youtu.be/kc9HwsxE1OY), or perhaps more crucially in the matlab worldview, by restricting the unlimited dynamism of the language to a more strict type hierarchy in function calls: you write many small atomic function-methods, meant to accept a few or even a single combination of types and let the dispatcher choose which implementation to call when the generic function-name is invoked. Arguably this leads to better compartmentalized development and subsequent easier maintenance, with respect to the usual big-and-generic-function-that-handles-it-all approach.

Currently we support:
- Dispatch on the number of arguments (both in and out![^1])
- Dispatch on the type of arguments (both intrinsic and custom[^2]) 
   
Planned:
- Dispatch on keyword arguments (via [`inputParser`](https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html)). It might take a while, for now just avoid varargins in the specialized implementations.

[^1]: This needs clarifications, I intend to write a careful note, for now 🚧 Work ⚠️ in 🪜 Progress 🚧

[^2]: Please note that you [can't define custom types as matlab structs](https://www.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html), since they have no name and all share `struct` as their type. You can instead implement your custom types with the [`classdef` keyword](https://www.mathworks.com/help/matlab/ref/classdef.html) and have it work fine with the matlab-multiple-dispatch API.

## Example of Usage

🚧 Work ⚠️ in 🪜 Progress 🚧
> we are changing API on this branch
---

## License and Copyright
The code is based on [original work](https://github.com/aminya/Dispatch.m) by A. Yahyaabadi, as such it inherits the [Apache v2 license](./LICENSE). Some fix and new functionality has been added by G. Bellomia and more changes are planned in the near future, especially regarding testing and profiling.
```
Copyright 2020 Amin Yahyaabadi [original dispatch.m function]    
Copyright 2022 Gabriele Bellomia [multimethod.interface class] 

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




