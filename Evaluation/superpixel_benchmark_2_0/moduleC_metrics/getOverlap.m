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
% Overlap is rate of common area on total area
%
function [R, L1t_sizes, L2_sizes] = getOverlap(L1, L2, F)

  % apply flow
  [L1t] = applyFlowTransform(L1, F, 'nearest'); % has been 'none' before
    
  nSegsL1t = max(L1(:));
  nSegsL2 = max(L2(:));
  
  L1t_sizes = zeros(nSegsL1t, 1);
  L2_sizes = zeros(nSegsL2, 1);
  A = zeros(nSegsL1t, nSegsL2);
  
  % collect label data
  for x=1:size(L1t,2)
    for y=1:size(L1t,1)
     
      L1t_val = L1t(y,x);
      L2_val = L2(y,x);
      
      L2_sizes( L2_val ) = L2_sizes( L2_val ) + 1;
      
      if ~isnan(L1t_val)
        L1t_sizes( L1t_val ) = L1t_sizes( L1t_val ) + 1;
        A(L1t_val, L2_val) = A(L1t_val, L2_val) + 1;
      end
      
    end
  end
  
  % compute rate on area
  R = zeros(nSegsL1t, nSegsL2);
  for L1t_val = 1:nSegsL1t
    for L2_val = 1:nSegsL2
     
      % total area of both segments
      ta = L1t_sizes(L1t_val) + L2_sizes(L2_val) - A(L1t_val, L2_val);
      
      % rate of common area on total area
      R(L1t_val, L2_val) = A(L1t_val, L2_val) / ta;
      
    end
  end
  
  
end