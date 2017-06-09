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
% [mde, sumFlowGradients, nBoundaryPixels] = getFlowErrorMDE(L1, F, L2, W)
% 
% Compute the Motion Discontinuity Error (MDE) based on label images L1, L2, 
% an optical flow field W and gradient weights computed with getFlowGradientWeights() 
% function.
% 
% Input:
% L1 ... First label image
% F  ... Flow field
% L2 ... Second label image [optional]
% W  ... Input flow gradients [optional]
% 
% Output:
% mde    
% sumFlowGradients  ... sum of flow gradients in W
% nBoundaryPixels   ... Number of boundary pixels in L1, respectively combined 
%                       boundaries of L1 and L2 if L2 is given
%                     
function [mde, sumFlowGradients, nBoundaryPixels] = getWeightedFlowGradientError(L1, F, L2, W)
    
    % flow gradients (and suppress invalid pixels)
    if ~exist('W', 'var') || isempty(W)
        W = getFlowGradientWeights(F,1);
    end
    sumFlowGradients = sum(W(:));
    
    % distance transform of boundaries of label image(s)
    % if there are two, use the combined boundary image
    B = multiLabelImage2boundaryImage(L1);
    if exist('L2', 'var') && ~isempty(L2)
        B = max(B, multiLabelImage2boundaryImage(L2));
    end
    D = bwdist(B,'euclidean');
   
    % Frobenius inner product
    mde = sum(sum(W .* D));
    
    % number of boundary pixels (number non zero elements)
    nBoundaryPixels = nnz(B);
end
