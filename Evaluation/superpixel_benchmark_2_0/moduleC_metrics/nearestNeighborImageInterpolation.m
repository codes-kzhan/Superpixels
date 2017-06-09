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
% I = nearestNeighborImageInterpolation(I)
%
% Fills nan pixels with pixel value of nearest non-nan pixel
% (slow)
%
% Input:
% I ... single channel image
% 
% Output:
% I ... The same as the input image, except that all NaN values are filled 
%       with value of nearest non NaN image pixel
%     
function I = nearestNeighborImageInterpolation(I)

    [h w c] = size(I);
    assert(c==1, 'Only single channel images supported');
    
    x = 1:w;
    y = 1:h;
    [X, Y] = meshgrid(x,y);
    
    idx = isnan(I);
    
    R = knnsearch([X(~idx) Y(~idx)],[X(idx) Y(idx)]);
    J = I(~idx);
    I(idx) = J(R);
        
    %I = knnimpute([X(:)*1e5; Y(:)*1e5; I(:)]); 
%     I(idx) = interp2(X(~idx), Y(~idx), I(~idx), X(idx), Y(idx),
%     'nearest');
%     I(idx) = interp2(X, Y, I, X(idx), Y(idx), 'nearest');
%     X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)),'cubic');
end