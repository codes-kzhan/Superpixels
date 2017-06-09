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
% [U V valid] = kitti_readFlow(KITTI_PATH, idx)
% 
% Load flow of a KITTI image
%
% Input: 
% KITTI_PATH ... path to Kitti dataset (use set_paths.m)
% 
% Output:
% U ... horizontal flow
% V ... vertical flow
% valid ... flag indicating whether the flow ist valid
%
function [U, V, valid] = kitti_readFlow(KITTI_PATH, idx)

    filename = fullfile(KITTI_PATH, 'flow_noc', sprintf('%06d_10.png', idx));


    % loads flow field F from png file
    % for details see KITTI readme.txt

    I = double(imread(filename));

    U = (I(:,:,1)-2^15)/64;
    V = (I(:,:,2)-2^15)/64;
    valid = min(I(:,:,3),1);
    U(valid==0) = 0;
    V(valid==0) = 0;
   
end