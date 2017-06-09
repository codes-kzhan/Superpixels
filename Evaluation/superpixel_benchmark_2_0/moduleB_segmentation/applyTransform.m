% Superpixel Benchmark
% Copyright (C) 2012  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% T = appplyTransform(I, A)
%
% Apply affine transformation on image. This function takes care of translations 
% by appending and removing rows and cols to obtain a coordinate system shift.
%
% I ... input image
% A ... affine transform (input for  maketform('affine')
% T ... transformed image
%
function T = appplyTransform(I, A)

    %% make affine transform
    tform = maketform('affine',A);
    
    %% apply if not just a pure translation (which is handled later on)
    if norm( A(1:2, 1:2) - [1 0; 0 1] ) > 0
      T = imtransform(I, tform, 'nearest', 'XYScale',1);
    else
      T = I;
    end

    %% to take effect of pure translations, append tx columns and ty rows
    tx = A(3,1);
    ty = A(3,2);
    
    % append first rows/cols if positive translation
    if tx>0
        T = [zeros(size(T,1), tx, size(T,3)), I];
    end
    if ty>0
        T = [zeros(ty, size(T,2), size(T,3)); T];
    end
    
    % remove first rows/cols if negative translation
    if tx<0
        T = T(:, (abs(tx)+1):size(T,2), :);
    end
    if ty<0
        T = T((abs(ty)+1):size(T,1),:, :);
    end
    
    
end