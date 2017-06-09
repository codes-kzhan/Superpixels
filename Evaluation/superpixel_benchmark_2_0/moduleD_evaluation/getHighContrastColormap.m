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
% [C L P] = getHighContrastColormap
% 
% Returns more or less high contrast format
% 
% Output:
% C ... Color
% L ... Line 
% P ... Marker
% 
% example usage:
%  [C L P] = getHighContrastColormap;
%  plot(x,y,'color', C(idx,:), 'LineStyle', L{idx});
%
function [C, L, P] = getHighContrastColormap(n)

  if ~exist('n', 'var'), n=30; end
     
  C = distinguishable_colors(n);

  L_base = {'-', '-.', '--'};
  L = repmat( L_base, 1, ceil(n/numel(L_base)));
  L = L(1:n);
  
  P_base = {'o','+','*','s','x','.','d','^','v','>','<','p','h'};
  P = repmat( P_base, 1, ceil(n/numel(P_base)));
  P = P(1:n);
  
end
