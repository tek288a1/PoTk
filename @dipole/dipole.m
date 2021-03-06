classdef dipole < pointSingularity
%dipole represents a dipole.
%
%  d = dipole(location, strength, angle, scale)
%    Constructs a dipole at a point in a potential domain. The scalar
%    strengh specifies the strength of the dipole. The argument angle 
%    specifies the angle of the dipole. The scale is a scaling factor for
%    the dipole flow associated with a conformal map to a physical domain;
%    see below.
%
%  If z(zeta) is a conformal map from the unit domain to a physical domain
%  and alpha is the location of the dipoel, the scaling factor is defined
%  by the expression
%
%                 scale
%    z(zeta) = ----------- + analytic part.
%              zeta - beta
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

properties(SetAccess=protected)
    angle = 0
    scale = 1
    
    greensXderivative
    greensYderivative
end

properties(Access=private)
    forSimplyConnected = false
    scaleWasGiven = false
    scaleWarningGiven = false
end

methods
    function d = dipole(location, strength, angle, scale)
        if ~nargin
            return
        end
        
        if nargin > 3
            d.scaleWasGiven = true;
            d.scale = scale;
        end
        
        if numel(location) ~= 1
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Location must be a single point.')
        end
        d.location = location;
        
        if ~(numel(strength) == 1 && imag(strength) == 0)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Strength must be a real scalar.')
        end
        d.strength = strength;
        
        if nargin > 2
            d.angle = angle;
        end
    end
    
    function d = struct(d)
        %Convert instance to structure.
        
        chi = d.angle;
        d = struct@pointSingularity(d);
        d.angle = chi;
    end
end

methods(Hidden)
    function val = evalPotential(d, z)
        if d.entirePotential
            if isfinite(d.location)
                val = d.strength./(z - d.location)/2/pi*exp(1i*d.angle);
            else
                val = d.strength*exp(-1i*d.angle)/2/pi*z;
            end
            return
        end
        
        val = complex(zeros(size(z)));
        
        U = d.strength;
        if U == 0
            return
        end
        
        if ~d.scaleWasGiven
            d.scaleWarning()
        end
        
        chi = d.angle;
        b = d.scale;
        if d.forSimplyConnected
            val = U*b*(exp(-1i*chi)*z + exp(1i*chi)./z);
            return
        end
        
        if mod(chi, pi) > eps(pi)
            % "Horizontal" component.
            dxg0 = d.greensXderivative;
            val = val - 4*pi*U*b*sin(chi)*dxg0(z);
        end
        if mod(chi + pi/2, pi) > eps(pi)
            % "Vertical" component.
            dyg0 = d.greensYderivative;
            val = val - 4*pi*U*b*cos(chi)*dyg0(z);
        end
    end
    
    function dw = getDerivative(d)
        if d.entirePotential
            if isfinite(d.location)
                dw = @(z) -d.strength./(z - d.location).^2/2/pi*exp(1i*d.angle);
            else
                dw = @(z) d.strength*exp(-1i*d.angle)/2/pi;
            end
            return
        end
        
        if ~d.scaleWasGiven
            d.scaleWarning()
        end
        
        U = d.strength;
        chi = d.angle;
        b = d.scale;
        if d.forSimplyConnected
            dw = @(z) U*b*(exp(-1i*chi) - exp(1i*chi)./z.^2);
            return
        end
        
        dzg0x = diff(d.greensXderivative);
        dzg0y = diff(d.greensYderivative);
        
        function v = deval(z)
            v = 0;
            
            if U == 0
                return
            end
            
            if mod(chi, pi) > eps(pi)
                v = v - 4*pi*U*b*sin(chi)*dzg0x(z);
            end
            if mod(chi + pi/2, pi) > eps(pi)
                v = v - 4*pi*U*b*cos(chi)*dzg0y(z);
            end
        end
        
        dw = @deval;
    end
    
    function d = setupPotential(d, W)
        D = W.domain;
        beta = d.location;
        if ~isin(D, beta)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'The dipole must be located inside the bounded circle domain.')
        end
        
        if d.strength == 0
            return
        end
        if D.m == 0
            d.forSimplyConnected = true;
            return
        end
        D = skpDomain(D);
        d.greensXderivative = greensC0Dpxy(beta, 'x', D);
        d.greensYderivative = greensC0Dpxy(beta, 'y', d.greensXderivative);
    end
end

methods(Access=protected)
    function scaleWarning(d)
        if d.scaleWarningGiven
            return
        end
        
        % FIXME: Really need a new ID string for this message.
        warning('PoTk:dipole:noScale', ...
                ['A scale for class %s should be specified ', ...
                'if there is a map to a physical domain, potential ', ...
                'since it may otherwise be inaccurate. Scale set to 1 ', ...
                'by default.'], class(d))
        d.scaleWarningGiven = true;
    end
    
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
