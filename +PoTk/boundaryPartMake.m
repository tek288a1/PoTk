function r = boundaryPartMake(domain, f0, f1)
% Specify different boundary conditions on unit disk c0 the other disks c_k, k > 0.

% Everett Kropf, 2016
% Rhodri Nelson, 2016
% 
% This file is part of the Potential Toolkit (PoTk).
% 
% PoTk is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% PoTk is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PoTk.  If not, see <http://www.gnu.org/licenses/>.

%boundaryPartMake makes a function to evaluate points on the boundary from
%a list of functions.
%
% r = boundaryPartMake(domain, f0, f1, ..., fm)
% Takes a list of functions and returns a function r which is restricted to
% the boundary. The function r gives f0 values for points on C0, f1 values
% for points on C1, etc., up to fm values for points on Cm.

% Everett Kropf, 2016

if ~isa(domain, 'skpDomain')
    error('First argument must be an "skpDomain" object.')
end

if ~all(cellfun(@(x) isa(x, 'function_handle'), {f0, f1}))
    error('Expected a list of function handles following the domain.')
end

function v = reval(z)
    v = nan(size(z));
    [~, onj] = ison(domain, z);
    v(onj==0)=f0(z(onj==0));
    for j = 1:domain.m
        ix = onj == j;
        v(ix) = f1(z(ix));
    end
end

r = @reval;

end
