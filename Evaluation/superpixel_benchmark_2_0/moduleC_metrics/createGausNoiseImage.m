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
% Add gaussian noise with stddev. s to image I
% I should be uint8
function J = createGausNoiseImage(I, s)

  if ~isa(I,'uint8')
    fprintf('Warnining in createSAPNoiseImage, I should be uint8\n');
  end
  
  [h,w,c] = size(I);
  

  % uint8 limits to [0 255] 
  J = uint8(double(I) + round(s*randn(h,w,c)));

  
end