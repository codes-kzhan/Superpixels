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
%
% Add salt and pepper noise to image I, d is the rate of pixels that
% switches to either black (=0) or white (=255)
% I should be three channel, uint8
function J = createSAPNoiseImage(I, d)

  if ~isa(I,'uint8')
    fprintf('Warnining in createSAPNoiseImage, I should be uint8\n');
  end
  
  [h,w,c] = size(I);
  
  if c~=3
    fprintf('Warnining in createSAPNoiseImage, I be a color image\n');
  end
  
  
  n = h*w;
    
  % select n*d pixels without replacement
  pidx = randperm(n); % random permutation of 1:n
  idxW = pidx(1:floor(n*d*0.5));
  idxB = pidx(floor(n*d*0.5)+1:floor(n*d));
  
  % modifiy color channels
  R = I(:,:,1);
  G = I(:,:,2);
  B = I(:,:,3);
  
  R(idxW) = 255;
  G(idxW) = 255;
  B(idxW) = 255;
  
  R(idxB) = 0;
  G(idxB) = 0;
  B(idxB) = 0;
  
  J = cat(3,R,G,B);
  
  
end