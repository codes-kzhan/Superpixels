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
% boundary_image = multiLabelImage2boundaryImage(mli, ignoreNanFlag)
% 
% Returns image with ones at all pixel where label in mli is different from
% its right or bottom neighbor, otherwise the image value is zero
%
% 
%
% Input:
% mli ... input image, pixels of same segment have same pixel value
% ignoreNanFlag ... If ignoreNanFlag is set, all pixels with Nan in mli do not cause a
%                   boundary.
%                 
% Output:
% boundary_image ... image with 1 at segment boundaries
%   
function boundary_image = multiLabelImage2boundaryImage(mli, ignoreNanFlag)

    if nargin<2
        ignoreNanFlag=0;
    end
    
    % right and bottom shift images
    mli_right = mli(:, 1:size(mli,2)-1);
    mli_bottom = mli(1:size(mli,1)-1, :);
    
    % substract
    mli_h_diff = zeros(size(mli));
    mli_v_diff = zeros(size(mli));
    
    mli_h_diff(:,1:size(mli,2)-1)  = (mli_right ~= mli(:, 2:size(mli,2)));
    mli_v_diff(1:size(mli,1)-1, :)  = (mli_bottom ~= mli(2:size(mli,1), :));

    % compute boundary image
    if ignoreNanFlag
        nanIdx = isnan(mli);
        nanIdx = imdilate(nanIdx, [1 1 0]);
        nanIdx = imdilate(nanIdx, [1 1 0]');
        boundary_image = ((mli_h_diff~=0) | (mli_v_diff~=0)) & ~nanIdx;    
    else
        boundary_image = ((mli_h_diff~=0) | (mli_v_diff~=0));    
    end
    
end