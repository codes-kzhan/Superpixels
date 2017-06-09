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
% Compute compactness from a label image L
%
% Here, compactness is defiend as teh ration between the area of a segment
% and the area of a circle of the same diameter
% diameter is the maximum diatcen between two boundary pixels
%
function com = getCompactnessDiameter(L)
  
  nSegs = max(L(:));
  nImPixel = numel(L);
  
  com = 0;
  s = diameter(L);   
  
  for i=1:nSegs
    d = s(i).Diameter;    
    nSegPixel = s(i).Area;
    if d>0 && nSegPixel>0
      
      % compute ratio segment area to circle area based on diameter
      segCom = nSegPixel / (pi*(d/2)^2);
      
      % compute weigthed sum
      w = nSegPixel / nImPixel;      
      com = com + w*segCom;
    end    
  end

  
end