classdef potential
%POTENTIAL is the complex potential.
%
%  W = potential(D, varargin)
%    Constructs the potential object given a unitDomain object D and zero
%    or more potentialKind objects.
%
%Once constructed, the potential at points zeta in the bounded unit domain
%may be evaluated by the syntax
%
%  val = W(zeta)
%
%See also unitDomain, potentialKind, listKinds.

% Everett Kropf, 2016
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

properties(SetAccess=protected)
    domain
    
    potentialFunctions
end

methods
    function W = potential(D, varargin)
        if ~nargin
            return
        end
        
        if ~isa(D, 'potentialDomain')
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Domain must be a "potentialDomain" object.')
        end
        W.domain = D;
        isPlane = isa(D, 'planeDomain');
        
        for i = 1:numel(varargin)
            if ~isa(varargin{i}, 'potentialKind')
                error(PoTk.ErrorIdString.InvalidArgument, ...
                    ['Expected a "potentialKind" object as argument in ' ...
                    'position %d.\nRecieved a "%s" instead.'], ...
                    i+1, class(varargin{i}))
            end
            
            pk = varargin{i};
            if ~isPlane
                pk = pk.setupPotential(W);
            else
                assert(pk.okForPlane, ...
                    PoTk.ErrorIdString.InvalidArgument, ...
                    ['Potential contribution "%s" makes no sense in ', ...
                    'the entire plane.'], class(pk))
                pk.entirePotential = true;
            end
            W.potentialFunctions{end+1} = pk;
        end
    end
    
    function val = feval(D, z)
        %Evaluate the potential at a point z.
        %  val = feval(D, z)
        
        if isempty(D.domain)
            val = nan(size(z));
            return
        end
        
        val = complex(zeros(size(z)));
        pf = D.potentialFunctions;
        for i = 1:numel(pf)
            val = val + pf{i}.evalPotential(z);
        end
    end
    
    function out = subsref(W, S)
        % Provide function-like behaviour.
        %
        %   W = potential(...);
        %   val = W(z);
        
        if numel(S) == 1 && strcmp(S.type, '()')
            out = feval(W, S.subs{:});
        else
            out = builtin('subsref', W, S);
        end
    end
end

end
