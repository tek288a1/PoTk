classdef UniformFlow < poUnitTest.TestCase
%poUnitTest.UniformFlow checks the uniform flow potential.

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

properties
    strength = 2
    angle = pi/4
    scale = 2
end

methods(Test)
    function checkFlow(test)
        test.dispatchTestMethod('flow')
    end
end

methods
    function entireFlow(test)
        m = test.strength;
        chi = test.angle;
        b = test.scale;
        
        uf = uniformFlow(m, chi, b);
        W = potential(test.domainObject, uf);
        ref = @(z) m*b*z*exp(-1i*chi);
        
        test.checkAtTestPoints(ref, W);
    end
end

end
