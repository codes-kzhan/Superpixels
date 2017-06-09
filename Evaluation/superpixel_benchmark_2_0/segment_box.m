% Superpixel Benchmark
% Copyright (C) 2015  Peer Neubert, peer.neubert@etit.tu-chemnitz.de
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
% [S time] = segment_box(image, n)
% 
% Perfom box segmentation
%
% Parameters
%   image      ... Matlab image
%   n          ... (approximate) number of superpixels 
%
% Returns
%   S    ... segment image
%   time ... execution time im ms of algorithm 
%
function [S, time] = segment_box(image,n)
   
    if ~exist('n','var') | isempty(n),   n = 100;   end
    
    % execute 
    tic();
    
    [h, w, c] = size(image);    
    B = zeros(h,w);
    
    ny = round(sqrt( n*h/w));
    nx = round(n/ny);
        
    dx = w/nx;
    dy = h/ny;
    
    for i=dx:dx:(w-1)
        B(:, round(i)) = 255;
    end
    
    for i=dy:dy:(h-1)
        B(round(i), :) = 255;
    end
    time = toc();
    
    % create multi-label-image
    S = uint16(boundaryImage2multiLabelImage(B));
    %time = 0;
    
end

function mli = boundaryImage2multiLabelImage(bim)
    inv_bim = max(bim(:))-bim;
    label_im = bwlabel(inv_bim,4);
    mli = imclose( label_im, strel([1 1 1; 1 1 1; 1 1 1]));
end
