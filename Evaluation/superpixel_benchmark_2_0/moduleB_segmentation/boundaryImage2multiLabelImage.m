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
% Converts a boundary image to a label image
%
function mli = boundaryImage2multiLabelImage(bim)

    inv_bim = max(bim(:))-bim;
    
    label_im = bwlabel(inv_bim,4);
    
%     figure(); title('in boundaryImage2multiLabelImage');
%     subplot(131); imshow(inv_bim, []);
%     subplot(132); imshow(label_im, []);
    
    mli = imclose( label_im, strel([1 1 1; 1 1 1; 1 1 1]));
%     subplot(133); imshow(mli, []);
    
end