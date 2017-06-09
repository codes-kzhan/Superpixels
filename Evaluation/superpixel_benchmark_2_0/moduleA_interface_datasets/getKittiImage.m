% Superpixel Benchmark
% Copyright (C) 201  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% kitti = getKittiImage(n)
% 
% Create paths to KITTI images. Uses set_paths.m
%
% Input:
% kitti_path  ... path to KITTI data
% n           ... number of Kitti images
% 
% Output:
% kitti.idx       ... image pair index [0...193]
% kitti.filename0 ... first image path
% kitti.filename1 ... second image path
%
function kitti = getKittiImage(kitti_path, n)
    
    if nargin<2
        n=194;
    end        
    
    for idx = 0:min(193, n-1)
        kitti(idx+1).idx = idx; 
        kitti(idx+1).filename0 = fullfile(kitti_path, 'image_0', sprintf('%06d_10.png', idx));
        kitti(idx+1).filename1 = fullfile(kitti_path, 'image_0', sprintf('%06d_11.png', idx));
    end
    
end