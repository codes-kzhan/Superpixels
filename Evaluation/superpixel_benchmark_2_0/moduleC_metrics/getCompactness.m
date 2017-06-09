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
% Compute compactness from a label image L following 
% "Measuring and evaluating the compactness of superpixels." 
% Schick, Alexander and Fischer, Mika and Stiefelhagen, Rainer
%
% s ... height and width of the structuring element for closing
function com = getCompactness(L, s)
  
  nSegs = max(L(:));
  nImPixel = numel(L);
  
  com = 0;
  L = double(L);
    
  for i=1:nSegs
    nSegPixel = nnz(L==i);
    if nSegPixel>0
      
      % compute boundary length
      M = L==i;
      if s>0
        M = imclose(M, ones(s,s));
      end
      
      MB = zeros(size(L,1)+2, size(L,2)+2);
      MB(2:end-1, 2:end-1) = M;
      
      B = multiLabelImage2boundaryImage( MB );      
      boundaryLength = nnz(B);
      
      if boundaryLength<1
        continue;
      end
      
      % compute ratio segment area to circle area based on boundary length
      segCom = 4*pi*nnz(M) / (boundaryLength^2);
      
      % compute weigthed sum
      w = nSegPixel / nImPixel;      
      com = com + w*segCom;
    end    
  end

  
end