% Superpixel Benchmark
% Copyright (C) 2013  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% -------------------------------------
% 
% W = getFlowGradientWeights(F,maskInvalidFlag)
% 
% Compute weight from gradients in flow field
% 
% Input:
% F               ... four channel flow image: u,v,valid, occluded
% maskInvalidFlag ... should invalid pixels be set to 0?
% 
% Output:
% W ... Gradient weight indicated by gradient magnitude
%   
function W = getFlowGradientWeights(F,maskInvalidFlag)

    if nargin<2
        maskInvalidFlag=0;
    end

    U = F(:,:,1);
    V = F(:,:,2);
    valid = F(:,:,3);

    [Ux,Uy] = gradient(U);
    [Vx,Vy] = gradient(V);
    
    W = sqrt( Ux.^2 + Uy.^2 + Vx.^2 + Vy.^2 );
%     W(~valid) = 0;
    if maskInvalidFlag
        invalid_dil = imdilate(1-valid, ones(3));
        W(invalid_dil~=0) = 0; 
    end
    
    
%     contour(v,v,z), hold on, quiver(v,v,px,py), hold off

end