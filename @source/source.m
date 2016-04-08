classdef source < pointSingularity
%source represents a source (or sink).
%
%  s = source(location, strength)
%    Constructs a point source in the bounded circular domain at location,
%    which must be a valid point inside a relatedly defined unitDomain
%    object. The strength is a scalar indicating the strength of the
%    source. A source (or sink) of equal and opposite strength is placed at
%    the location given by the property unitDomain.infImage, which
%    interpreted as the image of the point at infinity under a conformal
%    map from an unbounded physical domain to the bounded circular domain.
%    See the beta argument in the unitDomain class.
%
%See also potential, unitDomain.

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

properties(Access=protected)
    primeFunctions
end

methods
    function s = source(location, strength)
        if ~nargin
            return
        end
        
        if numel(location) ~= 1
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Location must be a single point.')
        end
        s.location = location;
        
        if ~(numel(strength) == 1 && imag(strength) == 0)
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Strength must be a real scalar.')
        end
        s.strength = strength;
    end
end
   
methods(Hidden)
    function val = evalPotential(s, z)
        omv = s.primeFunctions;
        val = s.strength*log(omv{1}(z).*omv{2}(z)...
            ./omv{3}(z)./omv{4}(z))/(2*pi);
    end
    
    function s = setupPotential(s, W)
        if isempty(W.theDomain.infImage)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'No image of infinity from the physical domain specified.')
        end
        D = skpDomain(W.theDomain);
        beta = W.theDomain.infImage;
        alpha = s.location;
        
        om = skprime(alpha, D);
        omv = {...
            om, ...
            skprime(1/conj(alpha), om), ...
            skprime(beta, om), ...
            skprime(1/conj(beta), om)};
        s.primeFunctions = omv;
    end
end

end
