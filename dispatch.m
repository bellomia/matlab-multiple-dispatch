function out = dispatch(var, fun_typeOrNum)
% performs runtime multiple dispatch for Matlab.
% # Example
% 
% put = dispatch(varargin,...
%     {@dog1, 1; % dispatch based on number of inputs
%     @dog2, ["logical","logical"];   % dispatch based on type
%     @dog3, ["numeric", "logical"];
%     @dog3, ["logical", "numeric"]; % repeated method for different type
%     @dog4, ["any", "logical"]})

methodNum = size(fun_typeOrNum,1); 
    for i=1:methodNum    
        if ismethod(var, fun_typeOrNum{i,2})
            out = fun_typeOrNum{i,1}(var{:});
        end
    end
    
    if ~exist('out','var')
       error("no method found") 
    end
end


function out = ismethod(var, numOrType)
% find if the method is correct based on number or type of arguments.
% calls isnargin and isa_ accordingly

    if isa(numOrType, 'numeric')
        out = isnargin(var, numOrType);
    else 
        out = isa_(var, numOrType);
    end
    
end


function out = isnargin(var, num)
% is number of var equal to num

   out = length(var) == num;
end


function out = isa_(var, type)
% vectorized isa
%
% # Example
% % use in type dispatch:
% isa_(varargin,{"any","any"})
% isa_(varargin,{"numeric","numeric"})
% isa_(varargin,{"double","single"})
% isa_(varargin,{"numeric","cell", "struct"})

% if number of arguments doesn't match the types, it returns false

    varlen = length(var); 
    typelen = length(type);
    
    varisa = false(typelen,1); % uses typelen and set default to false
    
    for i = 1:varlen
        varisa(i) = isa2(var{i},type{i});
    end
    
    out = all(varisa);
end

function out = isa2(var, type)
% custom isa function. It adds "any" type to Matlab

    if type == "any"
        out = true;
    else
        out = isa(var, type);
    end

end