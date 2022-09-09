function out = eisa(var, type)
% elemental isa
%
% # Example
% % use in type dispatch:
% eisa(varargin,{"any","any"})
% eisa(varargin,{"numeric","numeric"})
% eisa(varargin,{"double","single"})
% eisa(varargin,{"numeric","cell", "struct"})

% if number of arguments doesn't match the types, it returns false

    varlen = length(var);
    typelen = length(type);

    varisa = false(typelen,1); % uses typelen and set default to false

    for i = 1:varlen
        varisa(i) = isa_(var{i},type{i});
    end

    out = all(varisa);
end