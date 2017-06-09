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
% reverseStr = printProgress(text, i, n, reverseStr)
% 
% Print progress in form of an updated text line in the command window
%
% Example usage:
% 
% reverseStr=[];
% fprintf('before\n');
% for i=1:10
%   reverseStr = progressPrompt('Done %d of %d\n', i, 10, reverseStr);
% end
% fprintf('after\n');
%   
function reverseStr = printProgress(text, i, n, reverseStr)
  msg = sprintf(text, i, n);
  fprintf([reverseStr, msg]);
  reverseStr = repmat(sprintf('\b'), 1, length(msg));
end